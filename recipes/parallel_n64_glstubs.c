// Foyer compat layer for parallel-n64:
//   * desktop-GL functions and OES extensions glsm.c's feature
//     paths reference but never call on Switch (extension string
//     guards keep them dead at runtime; only need a link-time body)
//   * rsp_conf — globals that live in cxd4's rsp.c upstream; we
//     don't compile cxd4 (use rsp_hle), so vendor the same
//     definition locally to satisfy the libretro.c / api/config.c
//     references to CFG_HLE_GFX (= rsp_conf[0]).

// rsp_conf — CFG_HLE_GFX/CFG_HLE_AUD config bytes. Always-zero on
// Switch (we use rsp_hle exclusively), which means HLE-for-everything,
// matching the rsp_hle plugin's behavior.
unsigned char rsp_conf[32];

#include <GLES3/gl3.h>
#include <stddef.h>

void glProvokingVertex(GLenum mode) { (void)mode; }

void glTexImage2DMultisample(GLenum target, GLsizei samples,
    GLenum internalformat, GLsizei width, GLsizei height,
    GLboolean fixedsamplelocations) {
    (void)target; (void)samples; (void)internalformat;
    (void)width;  (void)height;  (void)fixedsamplelocations;
}

void glVertexAttribLPointer(GLuint index, GLint size, GLenum type,
    GLsizei stride, const void* pointer) {
    (void)index; (void)size; (void)type;
    (void)stride; (void)pointer;
}

void glGetBufferSubData(GLenum target, GLintptr offset,
    GLsizeiptr size, void* data) {
    (void)target; (void)offset; (void)size; (void)data;
}

void glBindFragDataLocation(GLuint program, GLuint color,
    const char* name) {
    (void)program; (void)color; (void)name;
}

void* glMapBufferOES(GLenum target, GLenum access) {
    (void)target; (void)access; return NULL;
}

GLboolean glUnmapBufferOES(GLenum target) {
    (void)target; return GL_FALSE;
}

void glBufferStorage(GLenum target, GLsizeiptr size,
    const void* data, GLbitfield flags) {
    (void)target; (void)size; (void)data; (void)flags;
}

void glTextureView(GLuint texture, GLenum target, GLuint origtexture,
    GLenum internalformat, GLuint minlevel, GLuint numlevels,
    GLuint minlayer, GLuint numlayers) {
    (void)texture; (void)target; (void)origtexture;
    (void)internalformat;
    (void)minlevel; (void)numlevels; (void)minlayer; (void)numlayers;
}

// glsm.c calls rglgen_resolve_symbols() with the libretro frontend's
// retro_hw_get_proc_address_t. We're using direct linkage to Switch
// Mesa's libGLESv2, so no resolution is needed — no-op.
typedef void (*rglgen_func_t)(void);
typedef rglgen_func_t (*rglgen_proc_address_t)(const char*);
void rglgen_resolve_symbols(rglgen_proc_address_t proc) {
    (void)proc;
}
