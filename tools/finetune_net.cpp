#include "caffe/caffe.hpp"
#include "caffe/error.hpp"

int main(int argc, char** argv) {
  LOG(FATAL) << "Deprecated. Use caffe train --solver=... "
                "[--weights=...] instead.";
  return 0;
}
