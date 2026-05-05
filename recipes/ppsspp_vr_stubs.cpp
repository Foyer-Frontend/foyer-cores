// Empty stubs for the VR symbols declared in
// Common/VR/PPSSPPVR.h. Pulled in by core_ppsspp on libnx because
// our recipe excludes the Common/VR/*.cpp implementations (they
// require <openxr/openxr.h>, which devkitPro doesn't ship for
// Switch). Other PPSSPP TUs still reference these symbols, so the
// linker needs *something* to resolve them; returning falsy /
// no-op satisfies the contract since IsVREnabled() always returns
// false on Switch and the rest of the VR path is then dead.

#include <cstddef>

struct AxisInput;
struct TouchInput;
struct KeyInput;

enum VRCompatFlag { VR_COMPAT_FLAG_DUMMY };
enum VRAppMode    { VR_APP_MODE_DUMMY    };

extern "C" {
    // Most of these are C++-mangled (declared without extern "C")
    // but for the ABI symbols the linker actually looks up, the
    // mangling matches the original declarations because we
    // redeclare with the same C++ signatures below. Keep this
    // block — it's empty intentionally.
}

bool IsVREnabled() { return false; }
void InitVROnAndroid(void*, void*, const char*, int, const char*) {}
void EnterVR(bool) {}
void GetVRResolutionPerEye(int* w, int* h) {
    if (w) *w = 0;
    if (h) *h = 0;
}
void SetVRCallbacks(void(*)(const AxisInput*, std::size_t),
                    bool(*)(const KeyInput&),
                    void(*)(const TouchInput&)) {}

void SetVRAppMode(VRAppMode) {}
void UpdateVRInput(bool, float, float) {}
bool UpdateVRAxis(const AxisInput*, std::size_t) { return false; }
bool UpdateVRKeys(const KeyInput&) { return false; }

void  PreprocessStepVR(void*) {}
void  SetVRCompat(VRCompatFlag, long) {}

void* BindVRFramebuffer() { return nullptr; }
bool  StartVRRender()       { return false; }
void  FinishVRRender()      {}
void  PreVRFrameRender(int) {}
void  PostVRFrameRender()   {}
int   GetVRFBOIndex()       { return 0; }
int   GetVRPassesCount()    { return 1; }
bool  IsPassthroughSupported() { return false; }
bool  IsBigScreenVRMode()      { return false; }
bool  IsFlatVRGame()           { return false; }
bool  IsFlatVRScene()          { return false; }
bool  IsGameVRScene()          { return false; }
bool  IsImmersiveVRMode()      { return false; }
bool  Is2DVRObject(float*, bool) { return false; }
void  UpdateVRParams(float*)         {}
void  UpdateVRProjection(float*, float*) {}
void  UpdateVRView(float*, float*)   {}
void  UpdateVRViewMatrices()         {}
