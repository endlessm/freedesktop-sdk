/*
 * Copyright (c) 2019 Codethink Ltd.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
#include "thread_pool.hpp"
#include "mapped_file.hpp"
#include "fd.hpp"
#include "named_tmp_file.hpp"
#include "arch.hpp"
#include "elfutils.hpp"
#include "run.hpp"

#include <fcntl.h>
#include <sys/stat.h>
#include <unistd.h>
#include <getopt.h>
#include <fstream>
#include <iostream>
#include <map>
#include <set>

struct result_t {
  known_arch arch;
  std::vector<std::string> source_files;
};


struct script {
  script():
    optimize(true),
    jobs(2*std::thread::hardware_concurrency()) {
  }

  std::unique_ptr<result_t>
  preprocess_file(std::filesystem::path const& p) {
    fd_t fd(p, O_RDONLY);
    auto st = fd.get_stat();
    if (st.st_size < (off_t)sizeof(Elf32_Ehdr)) {
      return nullptr;
    }
    mapped_file m(fd);
    auto header = static_cast<Elf32_Ehdr const*>(m.ptr(0));
    std::string magic(ELFMAG);
    if (magic.compare(0, SELFMAG, (char*)(header->e_ident), SELFMAG) != 0) {
      return nullptr;
    }
    auto arch = get_arch(header);
    if (has_debuglink(fd)) {
      return nullptr;
    }
    if (st.st_nlink > 1) {
      throw std::runtime_error("Multiple links!");
    }

    named_tmp_file listfile;

    int debugedit_status = run
      (std::vector<std::string>
       {"debugedit", "-i",
          "--list-file", listfile.get_path(),
          "--base-dir="+buildroot.string(),
          "--dest-dir="+destdir.string(),
          p.string()});
    if (debugedit_status != 0) {
      throw std::runtime_error("Unexpected exit from debugedit");
    }

    if (optimize) {
      int status = run(std::vector<std::string>{"eu-elfcompress", "--type=none", p.string()});
      if (status != 0) {
        throw std::runtime_error("Unexpected exit from eu-elfcompress");
      }
    }

    std::unique_ptr<result_t> result(new result_t{});

    result->arch = arch;

    std::ifstream liststream(listfile.get_path());
    while (liststream) {
      std::string path;
      getline(liststream, path, '\0');
      result->source_files.push_back(path);
    }

    return result;
  }

  bool classify() {
    std::vector<std::tuple<std::filesystem::path, std::future<std::unique_ptr<result_t> > > > results;

    constexpr auto exec =
      std::filesystem::perms::owner_exec
      | std::filesystem::perms::group_exec
      | std::filesystem::perms::others_exec;

    for (auto& p : std::filesystem::recursive_directory_iterator(install_root)) {
      auto status = symlink_status(p);

      if (status.type() == std::filesystem::file_type::regular) {
        auto name = p.path().filename().string();

        if (bool(status.permissions() & exec)
            || (name.rfind(".so") != std::string::npos)
            || ((name.length() >= 5) && (name.compare(name.length()-5, 5, ".cmxs") == 0))
            || ((name.length() >= 5) && (name.compare(name.length()-5, 5, ".node") == 0))) {
          results.push_back
            (std::make_tuple
             (p, pool->post([&, p] { return preprocess_file(p); })));
        }
      }
    }

    bool has_error = false;
    for (auto& result : results) {
      try {
        auto r = std::get<1>(result).get();
        if (!r)
          continue ;
        by_arch[r->arch].push_back(std::get<0>(result));
        for (auto const& source : r->source_files) {
          source_files.insert(source);
        }
      } catch (std::exception const& e) {
        has_error = true;
        std::cerr << std::get<0>(result) << ": " << e.what() << '\n';
      }
    }

    return !has_error;
  }

  bool run_opt() {
    std::vector<std::future<void> > opt_results;
    for (auto const& value : by_arch) {
      auto const& arch = std::get<0>(value);
      auto const& binaries = std::get<1>(value);
      auto do_optimize =
        [&, arch, binaries] {
          auto debug = dwzdir / get_triplet(arch);
          auto realpath = install_root / relative(debug, "/");
          create_directories(realpath.parent_path());
          std::vector<std::string> cmd{"dwz", "-m", realpath.string(), "-M", debug.string()};
          for (auto const& binary : binaries) {
            cmd.push_back(binary);
          }
          auto status = run(cmd);
          if (status != 0) {
            throw std::runtime_error("dwz failed");
          }
        };
      opt_results.push_back(pool->post(std::move(do_optimize)));
    }

    bool has_error = false;
    for (auto& result : opt_results) {
      try {
        result.get();
      } catch (std::exception const& e) {
        has_error = true;
        std::cerr << e.what() << '\n';
      }
    }

    return !has_error;
  }

  void strip_and_compress_file(std::filesystem::path const& toolchain,
                               std::filesystem::path const& binary)
  {
    auto realpath = relative(binary, install_root);
    auto debugfile = install_root / relative(debugdir, "/") / realpath;
    debugfile.replace_filename(debugfile.filename().string() + ".debug");

    create_directories(debugfile.parent_path());

    if (0 != run(std::vector<std::string>{(toolchain / "objcopy").string(),
                                            "--only-keep-debug", "--compress-debug-sections",
                                            binary, debugfile})) {
      throw std::runtime_error("objcopy failed");
    }

    chmod(debugfile.c_str(), 0644);
    auto st = status(binary);
    if (0 != access(binary.c_str(), W_OK)) {
      chmod(binary.c_str(), 0755);
    }

    if (0 != run(std::vector<std::string>{(toolchain / "strip").string(),
                                            "--remove-section=.comment",
                                            "--remove-section=.note",
                                            "--strip-unneeded",
                                            "--remove-section=.gnu_debugaltlink",
                                            binary})) {
      throw std::runtime_error("strip failed");
    }

    if (0 != run(std::vector<std::string>{(toolchain / "objcopy").string(),
                                            "--add-gnu-debuglink",
                                            debugfile,
                                            binary})) {
      throw std::runtime_error("objcopy failed");
    }

    if (0 != run(std::vector<std::string>{"eu-elfcompress", debugfile})) {
      throw std::runtime_error("eu-elfcompress failed");
    }

    chmod(binary.c_str(), (unsigned)st.permissions());
  }

  bool strip() {
    std::vector<std::tuple<std::filesystem::path, std::future<void> > > final_tasks;
    for (auto& value : by_arch) {
      auto& arch = std::get<0>(value);
      auto& binaries = std::get<1>(value);
      std::filesystem::path toolchain;
      try {
        toolchain = get_toolchain(toolchain_prefixes, arch);
      } catch (std::exception const& e) {
        std::cerr << e.what() << '\n';
        return false;
      }

      for (auto& binary : binaries) {
        auto task =
          [this, toolchain, binary] {
            strip_and_compress_file(toolchain, binary);
          };
        final_tasks.push_back(std::make_tuple(binary, pool->post(std::move(task))));
      }
    }

    bool has_error = false;
    for (auto& t : final_tasks) {
      try {
        std::get<1>(t).get();
      } catch (std::exception const& e) {
        has_error = true;
        std::cerr << std::get<0>(t) << ": " << e.what() << '\n';
      }
    }
    if (has_error)
      return false;

    return true;
  }

  void copy_source() {
    for (auto& source: source_files) {
      auto dst = install_root / relative(destdir, "/") / source;
      auto src = buildroot / source;

      if (!exists(dst)) {
        if (is_directory(src)) {
          create_directories(dst);
        } else if (exists(src)) {
          create_directories(dst.parent_path());
          copy_file(src, dst);
        }
      }
    }
  }

  bool operator()() {
    pool.reset(new thread_pool{jobs});

    if (!classify()) {
      return false;
    }

    auto source_copy_res = pool->post([this] { copy_source(); });

    if (optimize) {
      if (!run_opt())
        return false;
    }

    if (!strip())
      return false;

    source_copy_res.get();

    return true;
  }

  std::unique_ptr<thread_pool> pool;
  bool optimize;
  std::vector<std::string> toolchain_prefixes;
  std::size_t jobs;
  std::filesystem::path buildroot;
  std::filesystem::path destdir;
  std::filesystem::path dwzdir;
  std::filesystem::path debugdir;
  std::filesystem::path install_root;
  std::set<std::string> source_files;
  std::map<known_arch, std::vector<std::filesystem::path> > by_arch;
};

int main(int argc, char* argv[])
{
  script s;

  static struct option long_options[] =
    {
     {"no-optimize", no_argument, nullptr, 'n'},
     {"toolchain-prefix", required_argument, nullptr, 't'},
     {"jobs", required_argument, nullptr, 'j'},
     {nullptr, 0, nullptr, 0}
    };

  auto usage =
    [&] {
      std::cerr << "Usage: " << argv[0] << " [OPTIONS] BUILD_ROOT DESTDIR DWZDIR DEBUGDIR INSTALL_ROOT\n"
                << "  Options:\n"
                << "  -j|--jobs JOBS                Number of parallel jobs\n"
                << "  -n|--no-optimize              Disable dwz optimization\n"
                << "  -t|--toolchain-prefix PATH    Search for toolchain in that prefix\n";
    };

  while (true) {
    int option_index = 0;
    int c = getopt_long(argc, argv, "nt:j:",
                        long_options, &option_index);
    if (c == -1)
      break;

    switch (c) {
    case 'j': {
      std::istringstream iss(optarg);
      iss >> s.jobs;
      if (!iss.eof() || !iss.good()) {
        usage();
        exit(1);
      }
      break ;
    }
    case 'n':
      s.optimize = false;
      break ;
    case 't':
      s.toolchain_prefixes.push_back(optarg);
      break ;
    default:
      usage();
      return 1;
    }
  }

  std::vector<std::string> args;
  for (int i = optind; i < argc; ++i) {
    args.push_back(argv[i]);
  }

  if (args.size() != 5) {
    usage();
    return 1;
  }

  s.buildroot = args[0];
  s.destdir = args[1];
  s.dwzdir = args[2];
  s.debugdir = args[3];
  s.install_root = args[4];

  if (s()) {
    return 0;
  } else {
    return 1;
  }
}
