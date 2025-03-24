# -*- mode: python ; coding: utf-8 -*-


a = Analysis(
    ['running_game.py'],
    pathex=[],
    binaries=[],
    datas=[('images', 'images'), ('music', 'music'), ('running-game-animations', 'running-game-animations')],
    hiddenimports=[],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    noarchive=False,
    optimize=0,
)
pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.datas,
    [],
    name='running_game',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=False,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon=['running-game-animations/lives/lives.png'],
)
app = BUNDLE(
    exe,
    name='running_game.app',
    icon='running-game-animations/lives/lives.png',
    bundle_identifier=None,
)
