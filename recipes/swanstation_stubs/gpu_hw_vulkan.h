// Switch stub replacement for src/core/gpu_hw_vulkan.h.
//
// Upstream dropped the `u32` / `s32` typedefs from common/types.h — the
// HostDisplay virtuals are spelled uint32_t / int32_t now. Match them
// exactly so override-checking is happy and the derived class isn't
// abstract.

#pragma once
#include "core/host_display.h"
#include <libretro.h>

#include <cstdint>
#include <memory>

class LibretroVulkanHostDisplay final : public HostDisplay
{
public:
  LibretroVulkanHostDisplay();
  ~LibretroVulkanHostDisplay();

  static bool RequestHardwareRendererContext(retro_hw_render_callback* cb);

  RenderAPI GetRenderAPI() const override;
  void* GetRenderDevice() const override;
  void* GetRenderContext() const override;

  bool CreateRenderDevice(const WindowInfo& wi, std::string_view adapter_name, bool debug_device,
                          bool threaded_presentation) override;
  bool InitializeRenderDevice(std::string_view shader_cache_directory, bool debug_device,
                              bool threaded_presentation) override;
  void DestroyRenderDevice() override;

  void ResizeRenderWindow(int32_t new_window_width, int32_t new_window_height) override;

  bool ChangeRenderWindow(const WindowInfo& new_wi) override;

  std::unique_ptr<HostDisplayTexture> CreateTexture(uint32_t width, uint32_t height, uint32_t layers, uint32_t levels,
                                                    uint32_t samples, HostDisplayPixelFormat format, const void* data,
                                                    uint32_t data_stride, bool dynamic = false) override;
  bool SupportsDisplayPixelFormat(HostDisplayPixelFormat format) const override;
  bool BeginSetDisplayPixels(HostDisplayPixelFormat format, uint32_t width, uint32_t height, void** out_buffer,
                             uint32_t* out_pitch) override;
  void EndSetDisplayPixels() override;

  bool Render() override;

protected:
  bool CreateResources() override;
  void DestroyResources() override;
  // RenderSoftwareCursor is no longer virtual on HostDisplay upstream — keep
  // a no-op definition so the linker sees it, but don't mark it `override`.
  void RenderSoftwareCursor();
};
