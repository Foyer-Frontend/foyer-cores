// Force-included on parallel-n64 sources. parallel-n64's bundled
// libretro-common (older than upstream) declares glsm helpers in
// terms of desktop GL types — `GLclampd` in particular — that aren't
// in Switch's GLES2/3 headers. Switch's gl2ext.h already typedefs
// GLdouble, but not GLclampd. Provide it.
//
// glsm.c's implementation already routes to glDepthRangef under
// HAVE_OPENGLES, so this is purely a header-types fix; no runtime
// behavior changes.

#ifndef FOYER_PARALLEL_N64_COMPAT_H
#define FOYER_PARALLEL_N64_COMPAT_H

#include <GLES2/gl2.h>
#include <GLES2/gl2ext.h>

#ifndef GLclampd_defined
#define GLclampd_defined
typedef double GLclampd;
#endif

// gles2rice was written against desktop GL's clamp modes. GLES has
// only CLAMP_TO_EDGE / CLAMP_TO_BORDER; map the legacy GL_CLAMP
// (0x2900, "clamp to border with arbitrary border colour") onto
// CLAMP_TO_EDGE which is the closest universally-available behavior.
#ifndef GL_CLAMP
#define GL_CLAMP GL_CLAMP_TO_EDGE
#endif

// More fixed-function-only desktop-GL tokens referenced by gles2rice.
// Values are the canonical ones from <GL/gl.h>. They're only used as
// state-key arguments where the GLES driver will silently no-op
// unsupported keys, so providing the literals is enough to compile.
#ifndef GL_MAX_TEXTURE_UNITS
#define GL_MAX_TEXTURE_UNITS 0x84E2
#endif
#ifndef GL_INTERPOLATE
#define GL_INTERPOLATE       0x8575
#endif

#endif
