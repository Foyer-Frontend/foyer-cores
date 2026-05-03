// Foyer shim — see glsym.h. Pulls in Switch's full GLES 3.x +
// extension surface so glsm.c's GL function references resolve
// directly against Mesa's libGLESv2.

#ifndef FOYER_PN64_GLSYM_ES3_H
#define FOYER_PN64_GLSYM_ES3_H

#include <GLES3/gl3.h>
#include <GLES3/gl31.h>
#include <GLES3/gl32.h>
#include <GLES2/gl2ext.h>

// Some glsm code paths reference desktop-GL extensions that Switch
// Mesa doesn't expose as direct symbols. They're behind feature
// detection (the call sites check for the extension string before
// calling), so the function call only fires if the extension is
// advertised — which it never is on Switch. But the prototype must
// still be visible at compile time. Declare them as no-op stubs
// pulled into the libretro target via parallel_n64_glstubs.c.
#ifdef __cplusplus
extern "C" {
#endif

void glProvokingVertex(GLenum mode);
void glTexImage2DMultisample(GLenum target, GLsizei samples,
    GLenum internalformat, GLsizei width, GLsizei height,
    GLboolean fixedsamplelocations);
void glVertexAttribLPointer(GLuint index, GLint size, GLenum type,
    GLsizei stride, const void* pointer);
void glGetBufferSubData(GLenum target, GLintptr offset,
    GLsizeiptr size, void* data);
void glBindFragDataLocation(GLuint program, GLuint color,
    const char* name);
void* glMapBufferOES(GLenum target, GLenum access);
GLboolean glUnmapBufferOES(GLenum target);
void glBufferStorage(GLenum target, GLsizeiptr size,
    const void* data, GLbitfield flags);
void glTextureView(GLuint texture, GLenum target, GLuint origtexture,
    GLenum internalformat, GLuint minlevel, GLuint numlevels,
    GLuint minlayer, GLuint numlayers);

typedef void (*rglgen_func_t)(void);
typedef rglgen_func_t (*rglgen_proc_address_t)(const char*);
void rglgen_resolve_symbols(rglgen_proc_address_t proc);

#ifdef __cplusplus
}
#endif

#endif
