from conans import ConanFile, CMake, tools

class BinaryenConan(ConanFile):
    name = "binaryen"
    version = "version_101"
    license = "Apache-2.0"
    url = "https://github.com/WebAssembly/binaryen"
    description = "Cross-platform numerical analysis and data processing library"
    settings = "os", "compiler", "build_type", "arch"
    build_policy = "missing"
    generators = "cmake"
    _source_subfolder = "source_subfolder"

    def source(self):
        tools.get("%s/archive/refs/tags/%s.tar.gz" % (self.url, self.version), destination=self._source_subfolder, strip_root=True)

    def build(self):
        cmake = CMake(self)
        cmake.definitions["BUILD_STATIC_LIB"] = 1
        cmake.configure(source_folder=self._source_subfolder)
        cmake.build()

    def package(self):
        cmake = CMake(self)
        cmake.install()

    def package_info(self):
        self.cpp_info.libs = tools.collect_libs(self)
