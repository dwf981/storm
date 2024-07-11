#SingleInstance, Force
#NoTrayIcon
#Include <AuxLib>

    AuxLibLoad()

    SetRegView 64
    RegRead, DeveloperDir, HKCU\Software\Developer, DeveloperDir
    ProjectDir := GetProjectDir()

    if (A_Args.Length() > 0) {
        label := A_Args[1]
        if IsLabel(label) {
            Gosub %label%
        }
        ExitApp
    }

    ; Project Menu
    AddMenuItemEditor("ProjectMenu")
    AddMenu( "ProjectMenu" )
    AddMenu( "ProjectMenu", "&README.md...`tR", "OnReadme", BrowserPath )
    AddMenu( "ProjectMenu" )
    AddMenu( "ProjectMenu", "&Sync with Upstream`tS", "OnSyncWithUpstream", ConEmuPath )
    AddMenu( "ProjectMenu", "&STORM...`tS", "OnStormWsl", ResDir "github.ico" )
    AddMenu( "ProjectMenu", "Open &Config Local`tL", "OnOpenConfigLocal", VSCodePath )
    AddMenu( "ProjectMenu" )
    AddMenuItemEditProjectMenu("ProjectMenu")
    ShowMenu( "ProjectMenu" )
    ExitApp
return ; end of script's auto-execute section

MenuHandler:
    MsgBox % "MenuHandler was called."
return

OnSyncWithUpstream:
    SyncWithUpstream(ProjectDir, "https://github.com/jgravelle/AutoGroq.git")
return

OnStorm:
{
    SplitPath, A_LineFile,, ProjectDir
    SplitPath, ProjectDir,, ProjectDir
    ShiftPressed := GetKeyState("Shift","P")
    Script =
    (

        set ProjectName=storm
        set ProjectDir=%ProjectDir%
        set should_install=%ShiftPressed%
        call e exist param storm >nul 2>&1
        if "!errorlevel!" equ "1" set should_install=1

        if "!should_install!" equ "1" `(
            pushd "!ProjectDir!" || goto :exit
            echo.
            call e remove
            call e
            echo Installing Streamlit
            call conda install -c conda-forge streamlit
            echo Installing Python packages from requirements.txt
            pip install -r requirements.txt
            pip install "pydantic>=1.0,<2.0"
            popd
        `)

        pushd "!ProjectDir!" || goto :exit
        call e
        python examples\run_storm_wiki_gpt.py
        popd
    )
        
    RunBat({ Visible: "ConEmu", Colors: true, Pause: true }, StripBat( Script ) )
    return
}

OnStormWsl:
{
    SplitPath, A_LineFile,, ProjectDir
    SplitPath, ProjectDir,, ProjectDir

    WorkingDir := A_UserProfile

    ProjectDirWsl := ConvertToWslPath(ProjectDir)
    WorkingDirWsl := ConvertToWslPath(WorkingDir)
    ShiftPressed := GetKeyState("Shift","P")
    BatchScript =
    (

        echo !yellow!Running Storm in !green!%WorkingDir%!yellow! ...!nc!
        md "%WorkingDir%"
        dir /b /s "%WorkingDir%"
    )
    BashScript =
    (
        
        # Check if Storm is installed in the user home directory
        should_install=%ShiftPressed%
        if [[ -f "/home/ubuntu/anaconda3/envs/storm/bin/python" && "$should_install" == "0" ]]; then
            echo "Storm already installed."
            cd "%ProjectDirWsl%" || { echo "Failed to change directory."; exit 1; }
            source /home/ubuntu/anaconda3/etc/profile.d/conda.sh
            conda activate storm || { echo "Failed to activate environment."; exit 1; }
            python examples/run_storm_wiki_gpt.py
        else
            source /home/ubuntu/anaconda3/etc/profile.d/conda.sh

            echo "Creating new conda environment."
            rm -rf /home/ubuntu/anaconda3/envs/storm
            conda create -n storm python=3.11 -y || { echo "Failed to create environment."; exit 1; }

            echo "Activating the environment."
            conda activate storm || { echo "Failed to activate environment."; exit 1; }

            cd "%ProjectDirWsl%" || { echo "Failed to change directory."; exit 1; }
            pip install -r requirements.txt || { echo "Failed to install requirements."; exit 1; }

            echo "Storm installed successfully."
        fi
    )
    Options := { Visible: "ConEmu", Colors: true, Pause: true, Admin: false }
    RunBash( Options, StripBat(BatchScript), StripBat(BashScript), [], true, true )
    return
}

OnOpenConfigLocal:
{
    SplitPath, A_LineFile,, ProjectDir
    SplitPath, ProjectDir,, ProjectDir

    FilePath := ProjectDir . "\secrets.toml"

    Run, %VSCodePath% "%FilePath%"
    return
}
