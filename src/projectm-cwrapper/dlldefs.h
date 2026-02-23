#ifndef PROJECTM_CWRAPPER_DLLDEFS_H
#define PROJECTM_CWRAPPER_DLLDEFS_H

#ifndef DLLEXPORT
#if defined(_WIN32) || defined(__CYGWIN__)
#define DLLEXPORT __declspec(dllimport)
#else
#define DLLEXPORT
#endif
#endif

#endif
