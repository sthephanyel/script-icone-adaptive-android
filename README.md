## script-icone-adaptive-android

Esse projeto foi criado usando **Shell Script** em conjunto com outras Libs, para gerar de forma automatica os <a href="https://developer.android.com/develop/ui/views/launch/icon_design_adaptive?hl=pt-br" target="_blank">Icones Adaptativos</a> usados dentro de aplicativos criados com <a href="https://reactnative.dev/" target="_blank">React Native</a>, que são apresentados no aparelho do usuário.<br/>
Também altera as cores usadas na fundo(background) do icone no aparelho automaticamente.

<hr/>

## ✨ Features

- Gerar todos os icones que são usados pelo aplicativo em diferentes aparelhos.
- Ajustar a cor do fundo do icone (background), de forma automatica, com base na logo.
- Ajuste no tamanho das imagens para que não fujam do padrão.

## Modo de uso:
1: adiciona o arquivo script (correction_image_icon.sh), na raiz do projeto.

2: no terminal libere para que o sistema possa usar esse script:
> - chmod 755 ./correction_image_icon.sh
  
3: depois basta ativar o script:
> - ./correction_image_icon.sh

## Requisitos

- Sistema operacional Linux ou MacOs

## LIBS Necessárias
- Imagemagick (brew install imagemagick)
- Ghostscript (brew install ghostscript)
