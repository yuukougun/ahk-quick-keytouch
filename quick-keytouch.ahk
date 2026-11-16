#Requires AutoHotkey v2.0
#SingleInstance Force
;#HotIf の判定は、キーを押すたびにフックが本体に問い合わせて待つ。
;Windows はフックの応答が遅いと（既定 300ms）フックを黙って外すので、それより十分短くしておく
#HotIfTimeout 50

InstallKeybdHook()
A_MaxHotkeysPerInterval := 200
SetWorkingDir(A_ScriptDir)
;CPU が混んでいてもフックの応答が遅れにくいように優先度を上げる
ProcessSetPriority("High")

CoordMode("Mouse", "Screen")
CoordMode("ToolTip", "Screen")

LockPolicyKey := "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System"

numpadMode := false

;機能メニュー（無変換 + CapsLock）
FuncMenu := Menu()
FuncMenu.Add("&a メモ帳", (*) => ActivateOrRun("ahk_exe Notepad.exe", "Microsoft.WindowsNotepad_8wekyb3d8bbwe!App"))
FuncMenu.Add("&s 電卓", (*) => ActivateOrRun("電卓 ahk_class ApplicationFrameWindow", "Microsoft.WindowsCalculator_8wekyb3d8bbwe!App"))
FuncMenu.Add("&d ターミナル", (*) => ActivateOrRun("ahk_exe WindowsTerminal.exe", "Microsoft.WindowsTerminal_8wekyb3d8bbwe!App"))
FuncMenu.Add()
FuncMenu.Add("&f ショートカット一覧", ShowShortcutList)

;テンキーモードの割り当て
;#HotIf で切り替えるとキーを押すたびに判定の問い合わせが起きるので、Hotkey() でオン・オフする
NumpadKeys := [
    ["$7", "{Asc 55}"],   ;7
    ["$8", "{Asc 56}"],   ;8
    ["$+8", "{Asc 40}"],  ;(
    ["$9", "{Asc 57}"],   ;9
    ["$+9", "{Asc 41}"],  ;)
    ["u", "{Asc 52}"],    ;4
    ["i", "{Asc 53}"],    ;5
    ["o", "{Asc 54}"],    ;6
    ["j", "{Asc 49}"],    ;1
    ["k", "{Asc 50}"],    ;2
    ["l", "{Asc 51}"],    ;3
    ["m", "{Asc 48}"],    ;0
    ["$0", "{Asc 48}"],   ;0
    ["$,", "{Asc 44}"],   ;,
    ["$+,", "{Asc 60}"],  ;<
    ["$-", "{Asc 45}"],   ;-
    ["$+-", "{Asc 61}"],  ;=
    ["$.", "{Asc 46}"],   ;.
    ["$+.", "{Asc 62}"],  ;>
    ["$/", "{Asc 47}"],   ;/
    ["$^", "{Asc 94}"],   ;^
    ["$+^", "{Asc 126}"], ;~
    ["VKBA", "{Asc 42}"], ;*
    ["VKBB", "{Asc 43}"], ;+
    ["$VKDB", "{Asc 91}"], ;[
    ["$VKDD", "{Asc 93}"], ;]
    ["p", "{Backspace}"],
]
;a::Left のようなリマップと同じ動き（押している間は押しっぱなし、離したら離す）
NumpadRemaps := [["a", "Left"], ["d", "Right"], ["w", "Up"], ["s", "Down"]]
for item in NumpadKeys
    Hotkey(item[1], SendKeys.Bind(item[2]), "Off")
for item in NumpadRemaps {
    Hotkey("*" item[1], SendKeys.Bind("{Blind}{" item[2] " DownR}"), "Off")
    Hotkey("*" item[1] " up", SendKeys.Bind("{Blind}{" item[2] " Up}"), "Off")
}

;Win+L は Windows が直接ロックしてしまい「Win + 無変換 + l」（右寄せ）と両立できないので、
;起動中は Windows 側の Win+L を無効にして、代わりにこのスクリプトがロックする（終了時に元に戻す）
DisableLockWorkstation()
OnExit(EnableLockWorkstation)

;キー監視（フック）が外れていないかを見張る
;Raw Input はフックとは別の仕組みで届くので、「物理キーは届いているのにフックが何も見ていない」
;状態が続いたら、Windows にフックを外されたとみなして付け直す
lastPhysicalKeyTick := 0
RegisterRawKeyboard()
OnMessage(0x00FF, OnRawInput) ;WM_INPUT
SetTimer(CheckKeybdHook, 1000)

;緊急復帰用（フックを使わない登録方式なのでフックが外れても効く）
;登録方式は修飾キーが完全に一致しないと反応しないので、フックが外れて Shift や Win が
;押しっぱなしの扱いになっていても効くように、それらが付いた組み合わせも登録しておく
^!r::
^!+r::
#^!r::
#^!+r:: {
    Send("{Blind}{Shift Up}{Ctrl Up}{Alt Up}{LWin Up}{RWin Up}")
    Reload()
}

;ロック（Windows の Win+L の代わり）
#l:: {
    EnableLockWorkstation()
    DllCall("LockWorkStation")
    Sleep(1000)
    DisableLockWorkstation()
}

DisableLockWorkstation() {
    RegWrite(1, "REG_DWORD", LockPolicyKey, "DisableLockWorkstation")
}

EnableLockWorkstation(*) {
    try RegDelete(LockPolicyKey, "DisableLockWorkstation")
}

;方向キー
vk1D & j::ArrowKey("{Left}")
vk1D & l::ArrowKey("{Right}")
vk1D & i::ArrowKey("{Up}")
vk1D & k::ArrowKey("{Down}")

!i::Send("!{Up}")
!+i::Send("!+{Up}")
!^i::Send("!^{Up}")

!k::Send("!{Down}")
!+k::Send("!+{Down}")
!^k::Send("!^{Down}")

ArrowKey(key) {
    if (GetKeyState("LWin", "P") or GetKeyState("RWin", "P")) {
        ;ウィンドウの最大化・最小化・左右寄せ（Shiftを足すと別のモニターへ移動）
        Send(GetKeyState("Shift", "P") ? "#+" key : "#" key)
        return
    }
    SendWithShiftCtrl(key)
}

;押している Shift / Ctrl（物理キー）を付けて送る
SendWithShiftCtrl(key) {
    Send((GetKeyState("Shift", "P") ? "+" : "") (GetKeyState("Ctrl", "P") ? "^" : "") key)
}

SendKeys(keys, *) {
    Send(keys)
}

;デスクトップ切り替え(Lshift + RShift + a,dで切り替えに変更)
;<+>+ は左右両方の Shift が押されているときだけ反応する。#HotIf を使わないので a, d を打つたびの問い合わせが起きない
*<+>+a::Send("{Shift Up}#^{Left}")
*<+>+d::Send("{Shift Up}#^{Right}")

;実行
vk1D & h::SendWithShiftCtrl("{F5}")

;全体選択
vk1D & a::Send("^a")

;エスケープキー
vk1D & e::Send("{Esc}")

;保存
vk1D & s::Send("^s")

;エンター
vk1D & m::SendWithShiftCtrl("{Enter}")

;削除（Ctrlを足すと単語ごと）
vk1D & p::Send(GetKeyState("Ctrl", "P") ? "^{Backspace}" : "{Backspace}")

;コピペ
vk1D & n::Send("^c")
vk1D & x::Send("^x")
vk1D & ,::Send("^v")

;操作を戻す、やり直し
vk1D & u::Send(GetKeyState("Shift", "P") ? "{'}" : "^z")

vk1D & y::Send("^y")

;検索
vk1D & f::Send("^f")

;タブ・ファイルを閉じる
vk1D & w::Send("^w")

;半角全角切り替え
vk1D & o::Send("{vkF3sc029}")

;テンキー
;F13を押しっぱなしにする方式だと、ロック画面やUACを挟むと押下状態がずれて
;テンキーモードが外れなくなるので、スクリプト内の変数で管理する
vkF0:: {
    global numpadMode
    ;押しっぱなしのキーリピートで何度も切り替わるのを防ぐ
    if (A_PriorHotkey = A_ThisHotkey and A_TimeSincePriorHotkey < 150)
        return
    numpadMode := !numpadMode
    SetNumpadHotkeys(numpadMode)
    ;オンの間はマウスの横に表示し続ける
    if (numpadMode) {
        ShowNumpadTip()
        SetTimer(ShowNumpadTip, 50)
    } else {
        SetTimer(ShowNumpadTip, 0)
        ToolTip()
    }
}

ShowNumpadTip() {
    MouseGetPos(&mouseX, &mouseY)
    ToolTip("テンキー", mouseX + 40, mouseY + 16)
}

SetNumpadHotkeys(on) {
    state := on ? "On" : "Off"
    for item in NumpadKeys
        Hotkey(item[1], state)
    for item in NumpadRemaps {
        Hotkey("*" item[1], state)
        Hotkey("*" item[1] " up", state)
    }
}

;特殊操作
;Ctrlを足すとタブ切り替え
vk1D & .::SendWithShiftCtrl("{PgUp}")
vk1D & /::SendWithShiftCtrl("{PgDn}")

;Ctrlを足すと文書の先頭・末尾
vk1D & VKBB::SendWithShiftCtrl("{Home}")
vk1D & VKBA::SendWithShiftCtrl("{End}")

vk1D & @::Send("{Insert}")

;Ctrlを足すと単語ごと
vk1D & [::Send(GetKeyState("Ctrl", "P") ? "^{Delete}" : "{Delete}")

;shift大文字
vk1C::Shift

;&を入力（変換+Shift+t）
;vk1Cをリマップと「vk1C & t」のプレフィックスに二重で使うとShiftが押しっぱなしになることがあるので、
;プレフィックスにはせず物理キーの状態で判定する
#HotIf GetKeyState("vk1C", "P") and GetKeyState("Shift", "P")
+t::Send("{&}")
#HotIf

;機能メニュー
vk1D & vkF0:: {
    ;機能メニューを開いている間は a, s, d をメニューの選択に使うので、テンキーモードの割り当てを外す
    if (numpadMode)
        SetNumpadHotkeys(false)
    FuncMenu.Show()
    if (numpadMode)
        SetNumpadHotkeys(true)
}

;開いていれば前面に出し、なければ起動する
;スクリプトを管理者で動かしていると、そのまま Run したアプリも管理者になるので、
;エクスプローラー経由で起動して通常権限で開く
ActivateOrRun(winTitle, appId) {
    if WinExist(winTitle) {
        WinActivate()
        return
    }
    Run("explorer.exe shell:AppsFolder\" appId)
}

;README.md の「操作方法」にある表を一覧にして表示する
ShowShortcutList(*) {
    static shortcutGui := ""
    try {
        readme := FileRead(A_ScriptDir "\README.md", "UTF-8")
    } catch {
        MsgBox("README.md を読み込めませんでした。")
        return
    }
    if (shortcutGui)
        shortcutGui.Destroy()
    shortcutGui := Gui(, "ショートカット一覧")
    shortcutGui.SetFont("s10", "Meiryo UI")
    lv := shortcutGui.Add("ListView", "w760 r25 Grid", ["分類", "キー", "動作"])
    inSection := false
    category := ""
    Loop Parse readme, "`n", "`r" {
        line := A_LoopField
        if (SubStr(line, 1, 3) = "## ")
            inSection := (line = "## 操作方法")
        if (!inSection)
            continue
        if (SubStr(line, 1, 4) = "### ") {
            category := SubStr(line, 5)
            continue
        }
        ;表の中身の行だけ使う（見出し行と区切り行は飛ばす）
        if (SubStr(line, 1, 1) != "|" or InStr(line, "| ---") or InStr(line, "| キー |"))
            continue
        cells := StrSplit(Trim(line, "| "), "|", " ")
        ;テンキーモードの表は「キー | 入力」が横に3組並んでいるので2つずつ取り出す
        Loop cells.Length // 2 {
            key := StrReplace(cells[A_Index * 2 - 1], "``")
            action := StrReplace(cells[A_Index * 2], "``")
            if (key != "")
                lv.Add(, category, key, action)
        }
    }
    lv.ModifyCol()
    shortcutGui.OnEvent("Escape", (g) => g.Destroy())
    shortcutGui.OnEvent("Close", (g) => g.Destroy())
    shortcutGui.Show()
}

;Raw Input でキーボードの入力を受け取る（ほかのウィンドウが前面にあっても受け取る）
RegisterRawKeyboard() {
    ;RAWINPUTDEVICE: UsagePage=1 (Generic Desktop), Usage=6 (Keyboard), RIDEV_INPUTSINK
    rid := Buffer(8 + A_PtrSize, 0)
    NumPut("UShort", 1, "UShort", 6, "UInt", 0x100, "Ptr", A_ScriptHwnd, rid)
    DllCall("RegisterRawInputDevices", "Ptr", rid, "UInt", 1, "UInt", rid.Size)
}

OnRawInput(wParam, lParam, *) {
    global lastPhysicalKeyTick
    ;RAWINPUTHEADER の hDevice が 0 のものは SendInput などで送られた人工的な入力なので数えない
    headerSize := 8 + A_PtrSize * 2
    header := Buffer(headerSize, 0)
    DllCall("GetRawInputData", "Ptr", lParam, "UInt", 0x10000005, "Ptr", header, "UInt*", &headerSize, "UInt", headerSize) ;RID_HEADER
    if NumGet(header, 8, "Ptr")
        lastPhysicalKeyTick := A_TickCount
}

CheckKeybdHook() {
    global lastPhysicalKeyTick
    if (!lastPhysicalKeyTick)
        return
    sinceRawKey := A_TickCount - lastPhysicalKeyTick
    ;A_TimeIdleKeyboard はフックが最後に物理キーを見てからの時間
    if (sinceRawKey < 5000 and A_TimeIdleKeyboard > sinceRawKey + 2000) {
        lastPhysicalKeyTick := 0
        InstallKeybdHook(true, true)
        TrayTip("キー監視が外れていたので付け直しました", "quick-keytouch")
    }
}
