#include <stdbool.h>
#include "SDL3/SDL.h"

#ifndef FRAME_H
#define FRAME_H

#ifdef __cplusplus
extern "C" {
#endif

// ----------------------------
// SECTION: System 
// ----------------------------

int frame_create_window(int width, int height, const char* title, bool debug, const char* backend);
void frame_destroy_window(int window_id);
bool frame_is_window_running(int window_id);
void frame_set_window_running(int window_id, bool running);
int frame_get_window_width(int window_id);
int frame_get_window_height(int window_id);
bool frame_set_window_size(int window_id, int width, int height);
int frame_get_window_x(int window_id);
int frame_get_window_y(int window_id);
bool frame_set_window_position(int window_id, int x, int y);
int frame_get_current_display(int window_id);
bool frame_set_current_display(int window_id, int display);
int frame_get_primary_display();
bool frame_is_window_fullscreen(int window_id);
bool frame_toggle_fullscreen(int window_id, bool borderless);
bool frame_is_window_minimized(int window_id);
bool frame_minimize_window(int window_id);
bool frame_is_window_maximized(int window_id);
bool frame_maximize_window(int window_id);
bool frame_restore_window(int window_id);
bool frame_raise_window(int window_id);
bool frame_is_window_resizable(int window_id);
bool frame_set_window_resizable(int window_id, bool resizable);
bool frame_was_window_resized(int window_id);
bool frame_is_window_focused(int window_id);
bool frame_focus_window(int window_id);
void frame_set_window_icon(const char* icon);
bool frame_poll_window_events();
void frame_handle_window_events(int window_id);
void frame_handle_input_events();
void frame_set_fps_cap(int fps);
void frame_enable_fps_cap();
void frame_disable_fps_cap();
bool frame_is_fps_capped();
float frame_get_display_content_scale(int display);
float frame_get_window_display_scale(int window_id);
float frame_get_window_pixel_density(int window_id);
const char* frame_get_platform_name();

bool frame_is_cursor_shown();
void frame_show_cursor();
void frame_hide_cursor();
void frame_lock_cursor(int window_id);
void frame_unlock_cursor(int window_id);

void frame_set_clipboard_text(const char* text);
const char* frame_get_clipboard_text();

double frame_get_frame_time();
double frame_get_elapsed_time();

bool frame_is_key_down(int key);
bool frame_is_key_just_down(int key);
bool frame_is_key_released(int key);

bool frame_is_gamepad_available(int gamepad);
const char* frame_get_gamepad_name(int gamepad);
bool frame_is_gamepad_button_down(int gamepad, int button);
bool frame_is_gamepad_button_just_down(int gamepad, int button);
bool frame_is_gamepad_button_released(int gamepad, int button);
int frame_get_gamepad_axis_count(int gamepad);
float frame_get_gamepad_axis_movement(int gamepad, int axis);
void frame_set_gamepad_vibration(int gamepad, float left_motor, float right_motor, float duration_sec);

bool frame_is_mouse_button_down(int button);
bool frame_is_mouse_button_just_down(int button);
bool frame_is_mouse_button_released(int button);

int frame_get_mouse_position_x();
int frame_get_mouse_position_y();
void frame_set_mouse_position(int window_id, int x, int y);
float frame_get_mouse_wheel_movement_x();
float frame_get_mouse_wheel_movement_y();
void frame_set_mouse_cursor(int cursor);

// TODO: Touch

// ----------------------------
// SECTION: GPU
// ----------------------------

void frame_begin_render();
void frame_end_render();
void frame_set_clear_color(float r, float g, float b, float a);
void frame_begin_render_pass(int window_id, int render_pass_id, SDL_GPUTexture* color_target, SDL_GPUTexture* depth_target);
void frame_end_render_pass(int render_pass_id);

void frame_begin_copy_pass();
void frame_end_copy_pass();

SDL_GPUBuffer* frame_load_vertex_buffer(void* data, int size, bool cycle);
SDL_GPUBuffer* frame_load_index_buffer(void* data, int size, bool cycle);
void frame_unload_buffer(SDL_GPUBuffer* buffer);
int frame_create_storage_buffer(int size);
void frame_load_storage_buffer(int buffer, void* data, int size);
void frame_unload_storage_buffer(int buffer);

SDL_GPUTexture* frame_create_texture(int width, int height, int format, int usage, int mip, int layers, int type);
SDL_GPUTexture* frame_load_texture_from_bytes(void* data, int width, int height, int mip, int layers, int type);
SDL_GPUTexture* frame_load_texture_from_file(const char* file);
void frame_unload_texture(SDL_GPUTexture* texture);

SDL_GPUSampler* frame_load_sampler(int filter, int mipmap_mode, int address_mode, int max_anisotropy);
void frame_unload_sampler(SDL_GPUSampler* sampler);

SDL_GPUShader* frame_load_shader_from_bytes(void* data, int size, int stage, Uint32 sampler_count, Uint32 uniform_buffer_count, Uint32 storage_buffer_count, Uint32 storage_texture_count);
SDL_GPUShader* frame_load_shader_from_file(const char* file, int stage, Uint32 sampler_count, Uint32 uniform_buffer_count, Uint32 storage_buffer_count, Uint32 storage_texture_count);
void frame_unload_shader(SDL_GPUShader* shader);

void frame_set_vertex_data_size(int size);
void frame_add_vertex_attribute(int element_format, int location, int offset);
SDL_GPUGraphicsPipeline* frame_load_graphics_pipeline(SDL_GPUShader* vertex_shader, SDL_GPUShader* fragment_shader, bool depth_test, bool enable_blend, int src_color_blend_factor, int dst_color_blend_factor, int color_blend_op, int src_alpha_blend_factor, int dst_alpha_blend_factor, int alpha_blend_op);
void frame_unload_graphics_pipeline(SDL_GPUGraphicsPipeline* pipeline);

void frame_set_graphics_pipeline(SDL_GPUGraphicsPipeline* pipeline);

void frame_set_vertex_buffer(SDL_GPUBuffer* vertex_buffer);
void frame_set_index_buffer(SDL_GPUBuffer* index_buffer);
void frame_set_storage_buffer(int buffer);

void frame_set_vertex_uniform_data(int slot, void* data, int size); 
void frame_set_fragment_uniform_data(int slot, void* data, int size);
void frame_set_fragment_sampler(SDL_GPUTexture* texture, SDL_GPUSampler* sampler); 

void frame_draw_primitives(int vertices, int instances);
void frame_draw_indexed_primitives(int indices, int instances);

#ifdef __cplusplus
}
#endif

#endif
