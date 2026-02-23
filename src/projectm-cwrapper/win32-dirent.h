#ifndef DIRENT_INCLUDED
#define DIRENT_INCLUDED

#if defined(__MINGW32__) || defined(__MINGW64__)
#include <dirent.h>
#else

#ifdef __cplusplus
extern "C" {
#endif

typedef struct DIR DIR;

struct dirent
{
    char *d_name;
};

DIR           *opendir(const char *);
int           closedir(DIR *);
struct dirent *readdir(DIR *);
void          rewinddir(DIR *);
int scandir(const char* dir, struct dirent*** namelist,
            int(*filter)(const struct dirent*),
            int(*compar)(const void*, const void*));
int alphasort(const void* lhs, const void* rhs);

#ifdef __cplusplus
}
#endif

#endif /* MinGW */
#endif /* DIRENT_INCLUDED */
