#include <superblt_flat.h>

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <thread>

HWND _hWnd = nullptr;
lua_State* _pLuaState = nullptr; // pls don't cancel me thanks
lua_State* _pLuaStatePrev = nullptr; // same as above
bool _bEnabled = false;
bool _bState = true;

#define NX_CONSOLE 0 // enable debug console
#if NX_CONSOLE

static FILE* _pConsole = nullptr;

void openConsole()
{
	if (_pConsole == nullptr && AllocConsole())
	{
		SetConsoleTitleA("NX-Tweaks-Lib");
		freopen_s(&_pConsole, "CONOUT$", "w", stdout);
	}
}

void closeConsole()
{
	if (_pConsole != nullptr)
	{
		fclose(_pConsole);
		FreeConsole();
	}
}

//#define NX_PRINT(...) std::printf(__VA_ARGS__)
#define NX_PRINT(fmt, ...) std::printf(("%li | " + std::string(fmt)).c_str(), std::clock(), __VA_ARGS__)
#else
#define NX_PRINT(...) void(0)
#endif

#pragma region LUA_FUNCTION_EXPORTS

int Toggle(lua_State* L)
{
	_bEnabled = lua_toboolean(L, 1);

	NX_PRINT("Toggle: %i\n", _bEnabled);
	
	return 0;
}

/*int HasFocus(lua_State* L)
{
	const int result = (GetForegroundWindow() == _hWnd);

	lua_pushboolean(L, result); // first return value
	
	return 1; // number of return values
}*/

#pragma endregion LUA_FUNCTION_EXPORTS

#pragma region LUA_SETUP

void Plugin_Setup_Lua(lua_State* L) { /* Deprecated, see <superblt_flat.h> */ }

void Plugin_Init()
{
	PD2HOOK_LOG_LOG("Initializing NX-Tweaks");
	
	if ((_hWnd = FindWindow(L"diesel win32", L"PAYDAY 2")) == nullptr)
	{
		PD2HOOK_LOG_ERROR("Failed to find PAYDAY 2 window.");
		return;
	}
	
	PD2HOOK_LOG_LOG("NX-Tweaks loaded successfully.");

#if NX_CONSOLE
	openConsole();
#endif
}

void Plugin_Update() // called each frame
{
	static bool bFocus = true;
	const HWND hFocusNow = GetForegroundWindow();

	if (_pLuaStatePrev == nullptr)
		return;

	if ((hFocusNow == _hWnd) != bFocus) // focus changed
	{
		bFocus ^= 1;

		if (bFocus)
		{
			if (!_bState)
			{
				lua_getglobal(_pLuaStatePrev, "OnFocusGain");
				lua_call(_pLuaStatePrev, 0, 0);
				_bState = true;
			}
		}
		else
		{
			if (_bState && _bEnabled)
			{
				lua_getglobal(_pLuaStatePrev, "OnFocusLoss");
				lua_call(_pLuaStatePrev, 0, 0);
				_bState = false;
			}
		}
	}
}

int Plugin_PushLua(lua_State* L)
{
	lua_newtable(L);

	NX_PRINT("PushLua - %p\n", L);
	
	_pLuaStatePrev = _pLuaState;
	_pLuaState = L;

	lua_pushcfunction(L, Toggle);
	lua_setfield(L, -2, "toggle");
	
	return 1;
}

#pragma endregion LUA_SETUP
