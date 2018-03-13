#include "caffe/caffe.hpp"
#include "caffe/error.hpp"

int main(int argc, char** argv) {
  LOG(FATAL) << "Deprecated. Use caffe time --model=... "
             "[--iterations=50] [--gpu] [--device_id=0]";
  return 0;
}
