function [rawfile] = acquireRawImg()

loadlibrary('C:\Program Files\Point Grey Research\Spinnaker\bin64\vs2015\SpinnakerC_v140.dll', 'C:\Program Files\Point Grey Research\Spinnaker\include\spinc\SpinnakerC.h')
libfunctions('SpinnakerC_v140')

hCam = libpointer('spinCamera', 'voidPtr')
calllib('SpinnakerC_v140', 'spinCameraBeginAcquisition', hCam)

unloadlibrary('SpinnakerC_v140')