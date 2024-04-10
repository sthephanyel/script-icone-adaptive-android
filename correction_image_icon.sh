##!/usr/bin/env bash

# resumo_update.sh
#Autor:Sthephanyel
#Manutenção: Sthephanyel
#
# -------------------------------------------------------------*
#Descrição:
# Esse script pega a imagem base que existe dentro de res/playstore-icon.png, e usa como base para criar as outras imagems.
# -------------------------------------------------------------*
#Libs:
# brew install imagemagick
# brew install ghostscript


LOGO_512_512="android/app/src/main/res/playstore-icon.png"
LOGO_SIZE="$(identify -format "%wx%h" $LOGO_512_512)"
# echo $LOGO_SIZE
if [ -f "$LOGO_512_512" ]; then
    echo "Imagem encontrada."
    # open $LOGO_512_512
    if ( [ "$LOGO_SIZE" == "512x512" ] ); then
        echo "Imagem esta no tamanho correto"
    else
        echo "Logo ajustada"
        convert $LOGO_512_512 -interlace "none" -channel "RGBA" -resize 512x512 $LOGO_512_512;
    fi
else
    echo "Erro ao tentar encontrar a imagem."
    exit 1
fi

# Pega a cor em pixels da imagem, e define nos campos necessarios.
convert -size 50x50 xc:none -draw "roundrectangle 0,0,50,50,10,10" mask_img_color.png
convert -size 50x50! $LOGO_512_512 -shave 10 -matte mask_img_color.png -compose DstIn -composite point_base_logo_color.png

colorsImg="$(convert point_base_logo_color.png -scale 50x50! +dither -colors 10 -format "%c" histogram:info: | sed -n 's/^[ ]*\(.*\):.*[#]\([0-9a-fA-F]*\) .*$/\1,#\2/p' | sort -r -n -k 1 -t "," | cut -d "," -f 2 | cut -c 1-7)"
colorPrimary="$(echo $colorsImg | sed -e 's/[ ]//ig' | cut -c 8-14)"
echo "--------------------------------------------"
echo "CORES"
echo $colorsImg
echo "--------------------------------------------"
echo "COR PRINCIPAL"
echo $colorPrimary
echo "--------------------------------------------"
if ( [ "$colorPrimary" != "" ] )
then
echo "# ------------------------------------------------------------- #"
echo "Cor Alterada"
# troca o nome do app
tee "android/app/src/main/res/values/ic_launcher_background.xml" &>/dev/null <<EOF
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">${colorPrimary}</color>
</resources>
EOF
grep "${colorPrimary}" "android/app/src/main/res/values/ic_launcher_background.xml"


tee "android/app/src/main/res/values/colors.xml" &>/dev/null <<EOF
<resources>
    <color name="bootsplash_background">${colorPrimary}</color>
</resources>
EOF
grep "${colorPrimary}" "android/app/src/main/res/values/colors.xml"


tee "android/app/src/main/res/values/styles.xml" &>/dev/null <<EOF
<resources>

    <!-- Base application theme. -->
    <style name="AppTheme" parent="Theme.AppCompat.DayNight.NoActionBar">
        <!-- Customize your theme here. -->
        <item name="android:windowBackground">${colorPrimary}</item>
    </style>

    <style name="BootTheme" parent="Theme.BootSplash">
      <item name="bootSplashBackground">@color/bootsplash_background</item>
      <item name="bootSplashLogo">@drawable/bootsplash_logo</item>
      <item name="postBootSplashTheme">@style/AppTheme</item>
    </style>

</resources>
EOF
grep "${colorPrimary}" "android/app/src/main/res/values/styles.xml"

fi

# Entra nos arquivos das imagens e personaliza com os tamanhos corretos.
find "android/app/src/main/res/" -type f -name '*.png' -exec file {} \; > /tmp/a.txt
find "android/app/src/main/res/" -type f -name '*.png' | \
while read -r icon; do
size=$(convert "$icon" -print '%wx%h!' /dev/null);
echo "gerando $icon -> $size" ;
CAMPO="${icon##*/}"
sizeUno="$(echo $size | cut -d "x" -f 1)"
sizeUnoSub="$(expr $sizeUno - 1)"
linkArquivo="${icon%/*}"
echo "---------------------------------------------"
echo $icon
echo $linkArquivo
echo $CAMPO
echo $size
echo $sizeUno
echo $sizeUnoSub
echo "---------------------------------------------"
case $CAMPO in
    "ic_launcher_round.png")
        echo "redondo"
        cp "${LOGO_512_512}" "$icon" ;
        convert "$icon" -interlace "none" -channel "RGBA" -resize "$size" "$icon";
        convert -size $size xc:none -draw "roundrectangle 0,0,$sizeUnoSub,$sizeUnoSub,$sizeUnoSub,$sizeUnoSub" $linkArquivo/mask_rounded.png
        convert "$icon" -matte $linkArquivo/mask_rounded.png -compose DstIn -composite $linkArquivo/img_rounded.png
        convert $linkArquivo/img_rounded.png -bordercolor "none" -border "5x5" -interlace "none" -channel "RGBA" -resize "$size" $linkArquivo/img_rounded.png;
        cp $linkArquivo/img_rounded.png $linkArquivo/$CAMPO

        rm -rf $linkArquivo/img_rounded.png
        rm -rf $linkArquivo/mask_rounded.png

    ;;
    "ic_launcher_foreground.png")
        echo "foreground"
        cp "${LOGO_512_512}" "$icon" ;
        convert "$icon" -bordercolor "none" -border "230x230" -interlace "none" -channel "RGBA" -resize "$size" "$icon";
    ;;
    "bootsplash_logo.png")
        echo "foreground"
        cp "${LOGO_512_512}" "$icon" ;
        convert "$icon" -bordercolor "none" -border "400x400" -interlace "none" -channel "RGBA" -resize "$size" "$icon";
    ;;
    "ic_launcher.png")
        echo "ic_launcher"
        cp "${LOGO_512_512}" "$icon" ;
        convert "$icon" -interlace "none" -channel "RGBA" -resize "$size" "$icon";
        convert -size $size xc:none -draw "roundrectangle 0,0,$sizeUnoSub,$sizeUnoSub,20,20" $linkArquivo/mask_launcher_id.png
        convert "$icon" -matte $linkArquivo/mask_launcher_id.png -compose DstIn -composite $linkArquivo/img_launcher_id.png
        convert $linkArquivo/img_launcher_id.png -bordercolor "none" -border "15x15" -interlace "none" -channel "RGBA" -resize "$size" $linkArquivo/img_launcher_id.png;
        # convert "$icon" -bordercolor "none" -border "75x75" -interlace "none" -channel "RGBA" -resize "$size" "$icon";
        cp $linkArquivo/img_launcher_id.png $linkArquivo/$CAMPO

        rm -rf $linkArquivo/img_launcher_id.png
        rm -rf $linkArquivo/mask_launcher_id.png
    ;;
    *)
        echo "restante"
        cp "${LOGO_512_512}" "$icon" ;
        convert "$icon" -interlace "none" -channel "RGBA" -resize "$size" "$icon";
    ;;
esac
done
find "android/app/src/main/res/" -type f -name '*.png' -exec file {} \; > /tmp/b.txt
diff /tmp/a.txt /tmp/b.txt

rm -rf point_base_logo_color.png
rm -rf mask_img_color.png
