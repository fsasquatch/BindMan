import interop.Sdl.SDL_EventType;
import interop.Sdl.SDL_Event;
import interop.Sdl.SDL_WindowFlags;
import interop.Sdl.SDL;

class Def {
    	public static inline var INIT_VIDEO = 0x20;

	public static inline var WINDOW_OPENGL = 0x2;
	public static inline var WINDOW_HIDDEN = 0x8;
	public static inline var WINDOW_RESIZABLE = 0x20;
	public static inline var WINDOW_HIGH_PIXEL_DENSITY = 0x2000;

	public static inline var GL_RED_SIZE = 0;
	public static inline var GL_GREEN_SIZE = 1;
	public static inline var GL_BLUE_SIZE = 2;
	public static inline var GL_ALPHA_SIZE = 3;
	public static inline var GL_DOUBLEBUFFER = 5;
	public static inline var GL_STENCIL_SIZE = 7;
	public static inline var GL_CONTEXT_MAJOR_VERSION = 0x11;
	public static inline var GL_CONTEXT_MINOR_VERSION = 0x12;
	public static inline var GL_CONTEXT_PROFILE_MASK = 0x14;
	public static inline var GL_CONTEXT_PROFILE_ES = 0x4;

	public static inline var HINT_MOUSE_DOUBLE_CLICK_RADIUS = "SDL_MOUSE_DOUBLE_CLICK_RADIUS";
	public static inline var HINT_FRAMEBUFFER_ACCELERATION = "SDL_FRAMEBUFFER_ACCELERATION";
	public static inline var HINT_KEYCODE_OPTIONS = "SDL_KEYCODE_OPTIONS";
	public static inline var HINT_MOUSE_FOCUS_CLICKTHROUGH = "SDL_MOUSE_FOCUS_CLICKTHROUGH";
	/**
		The input method UI the app draws itself, set before `init`: "composition" when it draws the text being composed
		from `TextEditing` events (IBus and Fcitx then send it rather than showing it in their own window).
	**/
	public static inline var HINT_IME_IMPLEMENTED_UI = "SDL_IME_IMPLEMENTED_UI";

	public static inline var TOUCH_MOUSE_ID = -1;
	public static inline var PEN_MOUSE_ID = -2;
	public static inline var WHEEL_NORMAL = 0;

	public static inline var PIXELFORMAT_ARGB8888 = 0x16362004;
	public static inline var TEXTUREACCESS_STREAMING = 1;

	public static inline var BLENDMODE_NONE = 0;
	public static inline var BLENDMODE_BLEND = 1;

	public static inline var TEXTINPUT_TYPE_TEXT = 0;
	public static inline var TEXTINPUT_TYPE_TEXT_NAME = 1;
	public static inline var TEXTINPUT_TYPE_TEXT_EMAIL = 2;
	public static inline var TEXTINPUT_TYPE_TEXT_USERNAME = 3;
	public static inline var TEXTINPUT_TYPE_TEXT_PASSWORD_HIDDEN = 4;
	public static inline var TEXTINPUT_TYPE_TEXT_PASSWORD_VISIBLE = 5;
	public static inline var TEXTINPUT_TYPE_NUMBER = 6;
	public static inline var TEXTINPUT_TYPE_NUMBER_PASSWORD_HIDDEN = 7;
	public static inline var TEXTINPUT_TYPE_NUMBER_PASSWORD_VISIBLE = 8;

	public static inline var CAPITALIZE_NONE = 0;
	public static inline var CAPITALIZE_SENTENCES = 1;
	public static inline var CAPITALIZE_WORDS = 2;
	public static inline var CAPITALIZE_LETTERS = 3;

	public static inline var SCALEMODE_NEAREST = 0;
	public static inline var SCALEMODE_LINEAR = 1;

	public static inline var SYSTEM_CURSOR_DEFAULT = 0;
	public static inline var SYSTEM_CURSOR_TEXT = 1;
	public static inline var SYSTEM_CURSOR_WAIT = 2;
	public static inline var SYSTEM_CURSOR_CROSSHAIR = 3;
	public static inline var SYSTEM_CURSOR_PROGRESS = 4;
	public static inline var SYSTEM_CURSOR_NWSE_RESIZE = 5;
	public static inline var SYSTEM_CURSOR_NESW_RESIZE = 6;
	public static inline var SYSTEM_CURSOR_EW_RESIZE = 7;
	public static inline var SYSTEM_CURSOR_NS_RESIZE = 8;
	public static inline var SYSTEM_CURSOR_MOVE = 9;
	public static inline var SYSTEM_CURSOR_NOT_ALLOWED = 10;
	public static inline var SYSTEM_CURSOR_POINTER = 11;

	public static inline var KEY_ESCAPE = 0x1b;

	public static inline var SYSTEM_THEME_UNKNOWN = 0;
	public static inline var SYSTEM_THEME_LIGHT = 1;
	public static inline var SYSTEM_THEME_DARK = 2;
}

function main() {
    SDL.SDL_Init(Def.INIT_VIDEO);
    var window = SDL.SDL_CreateWindow("hello", 640, 480, Def.WINDOW_OPENGL | Def.WINDOW_RESIZABLE);
    var gl = SDL.SDL_GL_CreateContext(window);
    var event = new SDL_Event();

	var running = true;
    while(running) {
        while(SDL.SDL_PollEvent(event)) {
            if(event.type == cast SDL_EventType.SDL_EVENT_QUIT) {
                running = false;
            }
        }
        SDL.SDL_GL_SwapWindow(window);
    }

    SDL.SDL_GL_DestroyContext(gl);
    SDL.SDL_DestroyWindow(window);
    SDL.SDL_Quit();
}