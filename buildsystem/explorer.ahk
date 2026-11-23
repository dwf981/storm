#Requires AutoHotkey v2.0
#SingleInstance Off
#Warn All, OutputDebug

#Include <Explorer>

ProjectMenu() {
    items := ProjectMenu_Editor(false)
    items.Push({ text: "Open &PyCharm`tP", id: "OnOpenPyCharm", run: OnOpenPyCharm, icon: "@PyCharmPath" })
    items.Push("-", ProjectMenu_Readme(), "-")
    items.Push({ text: "&Sync with Upstream`tS", id: "OnSyncWithUpstream", run: OnSyncWithUpstream, icon: "@ConEmuPath" })
    items.Push({ text: "S&TORM...`tT", id: "OnStorm", run: OnStorm, icon: "github.ico" })
    items.Push({ text: "STORM &UI...`tU", id: "OnStormUI", run: OnStormUI, icon: "github.ico" })
    items.Push({ text: "&Open Secrets File`tO", id: "OnOpenSecretsFile", run: OnOpenSecretsFile, icon: "@VSCodePath" })
    items.Push("-")
    items.Push(ProjectMenu_EditMenu()*)
    return items
}

; This script lives in <repo>\buildsystem.
ScriptRepo() => RegExReplace(A_ScriptDir, "\\[^\\]+$")

OnSyncWithUpstream() => SyncWithUpstream(Explorer2_ProjectDir(), "https://github.com/stanford-oval/storm.git")

; Runs a command of the storm checkout in its conda environment (created on first use, or again with Shift).
StormRun(command) {
    Run_Bat({ Visible: "ConEmu", Colors: true, Pause: true, Vars: { ProjectDir: ScriptRepo(), Reinstall: Cli_Shift() ? "1" : "0", StormCommand: command } }, "
(
set ProjectName=storm
set should_install=!Reinstall!
call e exist param storm >nul 2>&1
if "!errorlevel!" equ "1" set should_install=1

if "!should_install!" equ "1" (
    pushd "!ProjectDir!" || goto :exit
    echo.
    call e remove
    call e
    popd
`)

pushd "!ProjectDir!" || goto :exit
call e
set PYTHONPATH=!PYTHONPATH!;!ProjectDir!
!StormCommand!
popd
)")
}

OnStorm() => StormRun("python examples\run_storm_wiki_gpt.py --output-dir . --retriever bing --do-research --do-generate-outline --do-generate-article --do-polish-article")

OnStormUI() => StormRun("streamlit run frontend\demo_light\storm.py")

OnOpenSecretsFile() {
    try Run('"' Tools.VSCodePath '" "' ScriptRepo() '\secrets.toml"')   ; cli-ok: the editor shows its own window
}

Explorer2_Main(ProjectMenu)
