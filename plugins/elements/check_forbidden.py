import os
from buildstream import Element, ElementError, Scope

class CheckForbiddenElement(Element):

    def configure(self, node):
        node.validate_keys(['forbidden'])

        self.forbidden = set(node.get_str_list('forbidden'))

    def preflight(self):
        pass

    def get_unique_key(self):
        return {'forbidden': sorted(list(self.forbidden))}

    def configure_sandbox(self, sandbox):
        pass

    def _find_bad_dependencies(self, elt, traversed):
        if elt in traversed:
            return False
        traversed.add(elt)
        bad = False
        for dep in elt.dependencies(Scope.RUN, recurse=False):
            if self._find_bad_dependencies(dep, traversed):
                self.warn('{} depends on {}'.format(elt, dep))
                bad = True
        if elt.name in self.forbidden:
            bad = True
        return bad

    def stage(self, sandbox):
        pass

    def assemble(self, sandbox):
        traversed = set()
        for dep in self.dependencies(Scope.BUILD, recurse=False):
            if self._find_bad_dependencies(dep, traversed):
                raise ElementError("Some elements were forbidden")
        return os.sep

def setup():
    return CheckForbiddenElement
