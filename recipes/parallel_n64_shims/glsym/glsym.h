// Foyer shim — replaces parallel-n64's bundled glsym dispatcher for
// the Switch build. The bundled version routes to glsym_es2.h /
// glsym_es3.h that declare GLES symbols as runtime function pointers
// resolved via rglgen. On Switch, Mesa's libGLESv2 exports the GLES3
// symbols directly, so we can skip the indirection and #include the
// platform headers.
//
// This file lives under recipes/parallel_n64_shims/glsym/ which is
// added to the include path BEFORE parallel-n64's bundled
// libretro-common, so any `#include <glsym/glsym.h>` resolves here.

#ifndef FOYER_PN64_GLSYM_H
#define FOYER_PN64_GLSYM_H

#include <glsym/glsym_es3.h>

#endif
