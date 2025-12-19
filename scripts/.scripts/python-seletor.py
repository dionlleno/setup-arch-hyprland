#!/usr/bin/env python3
# hypr-wallpaper-selector.py
#
# GUI simples em GTK para mostrar thumbnails de ~/Imagens/Wallpapers,
# ao clicar num wallpaper ele é copiado para ~/Imagens/Wallpapers/.wallpaper
# e aplicado com `swww img`.
#
# Dependências: python3-gi, pillow (opcional), swww

import gi

gi.require_version("Gtk", "3.0")
import os
import shutil
import subprocess
from pathlib import Path

from gi.repository import GdkPixbuf, GLib, Gtk

WALL_DIR = Path.home() / "Imagens" / "Wallpapers"
TARGET = WALL_DIR / ".wallpaper"  # caminho final pedido pelo usuário
THUMB_W = 320
THUMB_H = 200


class ThumbButton(Gtk.EventBox):
    def __init__(self, filepath, pixbuf):
        super().__init__()
        self.filepath = filepath
        img = Gtk.Image.new_from_pixbuf(pixbuf)
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
        label = Gtk.Label.new(os.path.basename(filepath))
        label.set_max_width_chars(20)
        label.set_ellipsize(Pango.EllipsizeMode.END) if False else None
        box.pack_start(img, True, True, 0)
        box.pack_start(label, False, False, 0)
        self.add(box)


class App(Gtk.Window):
    def __init__(self):
        super().__init__(title="Selector - Wallpapers (swww)")
        self.set_default_size(1000, 700)
        self.connect("destroy", Gtk.main_quit)

        self.grid = Gtk.ScrolledWindow()
        self.flow = Gtk.FlowBox()
        self.flow.set_max_children_per_line(6)
        self.flow.set_selection_mode(Gtk.SelectionMode.NONE)
        self.grid.add(self.flow)

        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        header = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        refresh_btn = Gtk.Button(label="Atualizar")
        refresh_btn.connect("clicked", lambda *_: self.populate())
        header.pack_start(refresh_btn, False, False, 6)

        apply_btn = Gtk.Button(label="Aplicar .wallpaper atual")
        apply_btn.connect("clicked", lambda *_: self.apply_existing())
        header.pack_start(apply_btn, False, False, 6)

        vbox.pack_start(header, False, False, 6)
        vbox.pack_start(self.grid, True, True, 0)

        self.add(vbox)
        self.populate()

    def populate(self):
        self.flow.foreach(lambda w: self.flow.remove(w))
        if not WALL_DIR.exists():
            WALL_DIR.mkdir(parents=True, exist_ok=True)
        for p in sorted(WALL_DIR.iterdir()):
            if p.is_file() and not p.name.startswith("."):
                try:
                    # cria thumbnail com GdkPixbuf
                    pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_scale(
                        str(p), THUMB_W, THUMB_H, True
                    )
                except Exception:
                    # se falhar, pula arquivo
                    continue
                frame = Gtk.EventBox()
                vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
                img = Gtk.Image.new_from_pixbuf(pixbuf)
                label = Gtk.Label(label=p.name)
                label.set_max_width_chars(20)
                vbox.pack_start(img, True, True, 0)
                vbox.pack_start(label, False, False, 0)
                frame.add(vbox)
                frame.connect("button-press-event", self.on_click, p)
                self.flow.add(frame)
        self.flow.show_all()

    def on_click(self, widget, event, filepath):
        # copia e aplica
        try:
            # sobrescreve .wallpaper
            shutil.copy2(filepath, TARGET)
            # chama swww para aplicar
            subprocess.run(["swww", "img", str(TARGET)], check=False)
            # opcional: show notification (se notify-send existir)
            subprocess.run(
                ["notify-send", "Wallpaper aplicado", os.path.basename(filepath)],
                check=False,
            )
        except Exception as e:
            dialog = Gtk.MessageDialog(
                parent=self,
                flags=0,
                message_type=Gtk.MessageType.ERROR,
                buttons=Gtk.ButtonsType.OK,
                text="Erro ao aplicar wallpaper",
            )
            dialog.format_secondary_text(str(e))
            dialog.run()
            dialog.destroy()

    def apply_existing(self):
        if TARGET.exists():
            subprocess.run(["swww", "img", str(TARGET)], check=False)
            subprocess.run(
                ["notify-send", "Wallpaper reaplicado", str(TARGET)], check=False
            )
        else:
            dialog = Gtk.MessageDialog(
                parent=self,
                flags=0,
                message_type=Gtk.MessageType.INFO,
                buttons=Gtk.ButtonsType.OK,
                text="Arquivo .wallpaper não existe",
            )
            dialog.run()
            dialog.destroy()


if __name__ == "__main__":
    # checar e criar pasta se necessário
    WALL_DIR.mkdir(parents=True, exist_ok=True)
    win = App()
    win.show_all()
    Gtk.main()
