#!/usr/bin/env python3
import os
import random
import shutil
import subprocess
import tkinter as tk
import ttkbootstrap as tb
from ttkbootstrap.constants import *
from PIL import Image, ImageTk

# ================= CONFIG =================

PASTA_IMAGENS = os.path.expanduser("~/Imagens/Wallpapers")
DESTINO = os.path.expanduser("~/Imagens/Wallpapers/.wallpaper")

SCRIPT_SDDM = "/usr/local/bin/update-sddm-wallpaper"

EXTENSOES = (".png", ".jpg", ".jpeg", ".webp", ".bmp")
PREVIEW_SIZE = (720, 420)

# =============== CORES NORD ===============

NORD_BG = "#2E3440"
NORD_PANEL = "#3B4252"
NORD_BORDER = "#434C5E"
NORD_TEXT = "#D8DEE9"
NORD_ACCENT = "#88C0D0"
NORD_BUTTON = "#5E81AC"
NORD_BUTTON_HOVER = "#81A1C1"

# =========================================


class WallpaperSelector(tb.Window):
    def __init__(self):
        super().__init__(
            title="Wallpaper Selector",
            themename="darkly",
            resizable=(False, False),
        )

        # -------- Hyprland style --------
        self.overrideredirect(True)
        self.geometry("1000x560")

        self._aplicar_tema_nord()

        self.imagens = []
        self.imagem_atual = None
        self.preview_img = None

        self._criar_layout()
        self._carregar_imagens()

    # ------------- TEMA ----------------

    def _aplicar_tema_nord(self):
        style = tb.Style()

        style.configure(".", background=NORD_BG, foreground=NORD_TEXT)
        style.configure("TFrame", background=NORD_BG)
        style.configure("TLabel", background=NORD_BG, foreground=NORD_TEXT)

        style.configure(
            "TButton",
            background=NORD_BUTTON,
            foreground=NORD_TEXT,
            borderwidth=0,
            padding=8,
        )

        style.map(
            "TButton",
            background=[("active", NORD_BUTTON_HOVER)],
            foreground=[("active", NORD_BG)],
        )

    # ---------------- UI ----------------

    def _criar_layout(self):
        main = tb.Frame(self, padding=10)
        main.pack(fill=BOTH, expand=True)

        # -------- Lista --------
        left = tb.Frame(main)
        left.pack(side=LEFT, fill=Y)

        self.lista = tk.Listbox(
            left,
            width=42,
            bg=NORD_PANEL,
            fg=NORD_TEXT,
            selectbackground=NORD_ACCENT,
            selectforeground=NORD_BG,
            highlightthickness=0,
            borderwidth=0,
            activestyle="none",
        )
        self.lista.pack(side=LEFT, fill=Y)
        self.lista.bind("<<ListboxSelect>>", self._ao_selecionar)

        scrollbar = tb.Scrollbar(left, orient=VERTICAL, command=self.lista.yview)
        scrollbar.pack(side=RIGHT, fill=Y)
        self.lista.config(yscrollcommand=scrollbar.set)

        # -------- Preview --------
        right = tb.Frame(main)
        right.pack(side=RIGHT, fill=BOTH, expand=True, padx=10)

        self.preview_label = tb.Label(
            right,
            text="Selecione um wallpaper",
            anchor=CENTER,
        )
        self.preview_label.pack(expand=True)

        # -------- Botões --------
        bottom = tb.Frame(self, padding=10)
        bottom.pack(fill=X)

        tb.Button(
            bottom,
            text="Definir",
            command=self.definir,
            width=20,
        ).pack(side=LEFT, expand=True, padx=20)

        tb.Button(
            bottom,
            text="Aleatório",
            command=self.aleatorio,
            width=20,
        ).pack(side=RIGHT, expand=True, padx=20)

    # ---------------- LÓGICA ----------------

    def _carregar_imagens(self):
        for raiz, _, arquivos in os.walk(PASTA_IMAGENS):
            for arq in arquivos:
                if arq.lower().endswith(EXTENSOES):
                    caminho = os.path.join(raiz, arq)
                    self.imagens.append(caminho)
                    self.lista.insert(
                        END, os.path.relpath(caminho, PASTA_IMAGENS)
                    )

    def _ao_selecionar(self, _):
        idx = self.lista.curselection()
        if not idx:
            return

        self.imagem_atual = self.imagens[idx[0]]
        self._atualizar_preview(self.imagem_atual)

    def _atualizar_preview(self, caminho):
        img = Image.open(caminho)
        img.thumbnail(PREVIEW_SIZE, Image.LANCZOS)
        self.preview_img = ImageTk.PhotoImage(img)
        self.preview_label.config(image=self.preview_img, text="")

    # ---------------- AÇÕES ----------------

    def _aplicar_wallpaper(self, caminho):
        shutil.copy(caminho, DESTINO)

        subprocess.run(
            ["swww", "img", str(caminho)],
            check=False,
        )

        subprocess.run(
                [
                    "notify-send",
                    "Wallpaper aplicado",
                    "Hyprland e SDDM atualizados",
                ],
                check=False,
            )

    def definir(self):
        if not self.imagem_atual:
            return
        self._aplicar_wallpaper(self.imagem_atual)

    def aleatorio(self):
        self.imagem_atual = random.choice(self.imagens)
        idx = self.imagens.index(self.imagem_atual)

        self.lista.selection_clear(0, END)
        self.lista.selection_set(idx)
        self.lista.see(idx)

        self._atualizar_preview(self.imagem_atual)
        self._aplicar_wallpaper(self.imagem_atual)


# ---------------- MAIN ----------------

if __name__ == "__main__":
    app = WallpaperSelector()
    app.mainloop()
