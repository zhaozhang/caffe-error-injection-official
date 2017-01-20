@echo off
@setlocal EnableDelayedExpansion

:: Default values
if DEFINED APPVEYOR (
    echo Setting Appveyor defaults
    if NOT DEFINED MSVC_VERSION set MSVC_VERSION=14
    if NOT DEFINED WITH_NINJA set WITH_NINJA=1
    if NOT DEFINED CPU_ONLY set CPU_ONLY=1
    if NOT DEFINED CMAKE_CONFIG set CMAKE_CONFIG=Release
    if NOT DEFINED CMAKE_BUILD_SHARED_LIBS set CMAKE_BUILD_SHARED_LIBS=0
    if NOT DEFINED PYTHON_VERSION set PYTHON_VERSION=2
    if NOT DEFINED BUILD_PYTHON set BUILD_PYTHON=1
    if NOT DEFINED BUILD_PYTHON_LAYER set BUILD_PYTHON_LAYER=1
    if NOT DEFINED BUILD_MATLAB set BUILD_MATLAB=0
    if NOT DEFINED PYTHON_EXE set PYTHON_EXE=python
    if NOT DEFINED RUN_TESTS set RUN_TESTS=1
    if NOT DEFINED RUN_LINT set RUN_LINT=1
    if NOT DEFINED RUN_INSTALL set RUN_INSTALL=1

    :: Set python 2.7 with conda as the default python
    if !PYTHON_VERSION! EQU 2 (
        set CONDA_ROOT=C:\Miniconda-x64
    )
    :: Set python 3.5 with conda as the default python
    if !PYTHON_VERSION! EQU 3 (
        set CONDA_ROOT=C:\Miniconda35-x64
    )
    set PATH=!CONDA_ROOT!;!CONDA_ROOT!\Scripts;!CONDA_ROOT!\Library\bin;!PATH!

    :: Check that we have the right python version
    !PYTHON_EXE! --version
    :: Add the required channels
    conda config --add channels conda-forge
    conda config --add channels willyd
    :: Update conda
    conda update conda -y
    :: Download other required packages
    conda install --yes cmake ninja numpy scipy protobuf==3.1.0 six scikit-image pyyaml

    if ERRORLEVEL 1  (
      echo ERROR: Conda update or install failed
      exit /b 1
    )

    :: Install cuda and disable tests if needed
    if !WITH_CUDA! == 1 (
        call %~dp0\appveyor\appveyor_install_cuda.cmd
        set CPU_ONLY=0
        set RUN_TESTS=0
    ) else (
        set CPU_ONLY=1
    )

    :: Disable the tests in debug config
    if "%CMAKE_CONFIG%" == "Debug" (
        echo Disabling tests on appveyor with config == %CMAKE_CONFIG%
        set RUN_TESTS=0
    )

    :: Disable linting with python 3 until we find why the script fails
    if !PYTHON_VERSION! EQU 3 (
        set RUN_LINT=0
    )

) else (
    :: Change the settings here to match your setup
    :: Change MSVC_VERSION to 12 to use VS 2013
    set MSVC_VERSION=14
    :: Change to 1 to use Ninja generator (builds much faster)
    set WITH_NINJA=1
    :: Change to 1 to build caffe without CUDA support
    set CPU_ONLY=0
    :: Change to Debug to build Debug. This is only relevant for the Ninja generator the Visual Studio generator will generate both Debug and Release configs
    set CMAKE_CONFIG=Release
    :: Change to 1 to build a caffe.dll
    set CMAKE_BUILD_SHARED_LIBS=0
    :: Change to 3 if using python 3.5 (only 2.7 and 3.5 are supported)
    set PYTHON_VERSION=2
    :: Change these options for your needs.
    set BUILD_PYTHON=1
    set BUILD_PYTHON_LAYER=1
    set BUILD_MATLAB=0
    :: If python is on your path leave this alone
    set PYTHON_EXE=python
    :: Run the tests
    set RUN_TESTS=0
    :: Run lint
    set RUN_LINT=0
    :: Build the install target
    set RUN_INSTALL=0

    :: Enable CUDA backend
    if NOT DEFINED USE_CUDA set USE_CUDA=0
    :: Use cuDNN acceleration with CUDA backend
    if NOT DEFINED USE_CUDNN set USE_CUDNN=0
    :: Use OpenCL backend
    if NOT DEFINED USE_GREENTEA set USE_GREENTEA=1
    :: Use LibDNN acceleration with OpenCL and/or CUDA backend
    if NOT DEFINED USE_LIBDNN set USE_LIBDNN=1
    :: Use OpenMP (disable this on systems with #NUMA > 1)
    if NOT DEFINED USE_OPENMP set USE_OPENMP=0
    :: Use 64 bit indexing for very large memory blob support (above 2G)
    if NOT DEFINED USE_INDEX64 set USE_INDEX64=0
    :: Use Intel spatial kernels acceleration for forward convolution on Intel iGPUs
    if NOT DEFINED USE_INTEL_SPATIAL set USE_INTEL_SPATIAL=0
)

:: Set the appropriate CMake generator
:: Use the exclamation mark ! below to delay the
:: expansion of CMAKE_GENERATOR
if %WITH_NINJA% EQU 0 (
    if "%MSVC_VERSION%"=="14" (
        set CMAKE_GENERATOR=Visual Studio 14 2015 Win64
    )
    if "%MSVC_VERSION%"=="12" (
        set CMAKE_GENERATOR=Visual Studio 12 2013 Win64
    )
    if "!CMAKE_GENERATOR!"=="" (
        echo ERROR: Unsupported MSVC version
        exit /B 1
    )
) else (
    set CMAKE_GENERATOR=Ninja
)

echo INFO: ============================================================
echo INFO: Summary:
echo INFO: ============================================================
echo INFO: MSVC_VERSION               = !MSVC_VERSION!
echo INFO: WITH_NINJA                 = !WITH_NINJA!
echo INFO: CMAKE_GENERATOR            = "!CMAKE_GENERATOR!"
echo INFO: CPU_ONLY                   = !CPU_ONLY!
echo INFO: USE_CUDA                   = !USE_CUDA!
echo INFO: USE_CUDNN                  = !USE_CUDNN!
echo INFO: USE_GREENTEA               = !USE_GREENTEA!
echo INFO: USE_LIBDNN                 = !USE_LIBDNN!
echo INFO: USE_OPENMP                 = !USE_OPENMP!
echo INFO: USE_INDEX64                = !USE_INDEX_64!
echo INFO: USE_INTEL_SPATIAL          = !USE_INTEL_SPATIAL!
echo INFO: CMAKE_CONFIG               = !CMAKE_CONFIG!
echo INFO: CMAKE_BUILD_SHARED_LIBS    = !CMAKE_BUILD_SHARED_LIBS!
echo INFO: PYTHON_VERSION             = !PYTHON_VERSION!
echo INFO: BUILD_PYTHON               = !BUILD_PYTHON!
echo INFO: BUILD_PYTHON_LAYER         = !BUILD_PYTHON_LAYER!
echo INFO: BUILD_MATLAB               = !BUILD_MATLAB!
echo INFO: PYTHON_EXE                 = "!PYTHON_EXE!"
echo INFO: RUN_TESTS                  = !RUN_TESTS!
echo INFO: RUN_LINT                   = !RUN_LINT!
echo INFO: RUN_INSTALL                = !RUN_INSTALL!
echo INFO: ============================================================

:: Build and exectute the tests
:: Do not run the tests with shared library
if !RUN_TESTS! EQU 1 (
  if %CMAKE_BUILD_SHARED_LIBS% EQU 1 (
      echo WARNING: Disabling tests with shared library build
    set RUN_TESTS=0
  )
)

<<<<<<< HEAD
:: Create build directory and configure cmake
:: if EXIST build (
::     echo ERROR: build directory already exists in %cd%\build please remove it and start over.
::     exit /b 1
:: )

if NOT EXIST build (
  mkdir build
)
pushd build

:: Download dependencies from VS x64
if NOT EXIST "%cd%\libraries" (
  echo INFO: Downloading dependencies
  "%PYTHON_EXE%" "%~dp0\download_prebuilt_dependencies.py" --msvc_version v%MSVC_VERSION%0
)

if ERRORLEVEL 1 (
  echo ERROR: Downloading dependencies failed
  exit /b 1
)


:: Add the dependencies to the PATH
if EXIST "%cd%\libraries\prependpath.bat" (
    call "%cd%\libraries\prependpath.bat"
)

=======
if NOT EXIST build mkdir build
pushd build

>>>>>>> 8a49d455c3589d4616a6f6191d6226353d13421e
:: Setup the environement for VS x64
set batch_file=!VS%MSVC_VERSION%0COMNTOOLS!..\..\VC\vcvarsall.bat
call "%batch_file%" amd64

:: Configure using cmake and using the caffe-builder dependencies
:: Add -DCUDNN_ROOT=C:/Projects/caffe/cudnn-8.0-windows10-x64-v5.1/cuda ^
:: below to use cuDNN
cmake -G"!CMAKE_GENERATOR!" ^
      -DBLAS=Open ^
      -DCMAKE_BUILD_TYPE:STRING=%CMAKE_CONFIG% ^
      -DBUILD_SHARED_LIBS:BOOL=%CMAKE_BUILD_SHARED_LIBS% ^
      -DBUILD_python:BOOL=%BUILD_PYTHON% ^
      -DBUILD_python_layer:BOOL=%BUILD_PYTHON_LAYER% ^
      -DBUILD_matlab:BOOL=%BUILD_MATLAB% ^
      -DCPU_ONLY:BOOL=%CPU_ONLY% ^
	  -DUSE_CUDA:BOOL=%USE_CUDA% ^
      -DUSE_CUDNN:BOOL=%USE_CUDNN% ^
	  -DUSE_LIBDNN:BOOL=%USE_LIBDNN% ^
	  -DUSE_GREENTEA:BOOL=%USE_GREENTEA% ^
	  -DUSE_OPENMP:BOOL=%USE_OPENMP% ^
      -DUSE_INDEX64:BOOL=%USE_INDEX64% ^
      -DUSE_INTEL_SPATIAL:BOOL=%USE_INTEL_SPATIAL% ^
      -DCOPY_PREREQUISITES:BOOL=1 ^
      -DINSTALL_PREREQUISITES:BOOL=1 ^
      "%~dp0\.."

if ERRORLEVEL 1 (
  echo ERROR: Configure failed
  exit /b 1
)

:: Lint
if %RUN_LINT% EQU 1 (
    cmake --build . --target lint  --config %CMAKE_CONFIG%
)

if ERRORLEVEL 1 (
  echo ERROR: Lint failed
  exit /b 1
)

:: Build the library and tools
cmake --build . --config %CMAKE_CONFIG%

if ERRORLEVEL 1 (
  echo ERROR: Build failed
  exit /b 1
)

:: Build and exectute the tests
if !RUN_TESTS! EQU 1 (
    cmake --build . --target runtest --config %CMAKE_CONFIG%

    if ERRORLEVEL 1 (
        echo ERROR: Tests failed
        exit /b 1
    )

    if %BUILD_PYTHON% EQU 1 (
        if %BUILD_PYTHON_LAYER% EQU 1 (
            :: Run python tests only in Release build since
            :: the _caffe module is _caffe-d is debug
            if "%CMAKE_CONFIG%"=="Release" (
                :: Run the python tests
                cmake --build . --target pytest

                if ERRORLEVEL 1 (
                    echo ERROR: Python tests failed
                    exit /b 1
                )
            )
        )
    )
)

if %RUN_INSTALL% EQU 1 (
    cmake --build . --target install --config %CMAKE_CONFIG%
)

popd
@endlocal
