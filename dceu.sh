#!/usr/bin/env bash
#
# dceu.sh - Lista de filmes do DCEU
#
# Site:       https://github.com/fabricio-esper
# Autor:      Fabrício Esper
# Manutenção: Fabrício Esper
#
# ------------------------------------------------------------------------ #
#  Este programa lista, com dialog, os filmes do DCEU de acordo com o site
#  imdb.com, através do lynx.  
#  
#  Exemplos:
#     $ ./dceu.sh
#     Neste exemplo o script será executado e mostrará a interface em dialog.
# ------------------------------------------------------------------------ #
# Histórico:
# v1.0 14/01/2022, Fabrício:
#     - Início do programa
#     - Adicionado parâmetro -h, -v, -s, -m & -c
# v1.1 17/01/2022, Fabrício:
#     - Adicionado cores
# v2.0 19/01/2022, Fabrício:
#     - Busca lista de filmes através do Lynx
# v2.1 21/01/2022, Fabrício:
#     - Adicionado parâmetro -a
# v2.2 21/01/2022, Fabrício:
#     - Adicionado interface gráfica com dialog
#     - Removido parâmetros -s, -m, -c & -a para substituir por opções no menu
# ------------------------------------------------------------------------ #
# Testado em:
#   bash 5.1.8
#   zsh 5.8
# ------------------------------------------------------------------------ #

# ------------------------------- VARIÁVEIS ---------------------------------------- #
DCEU="DCEU.txt"
TEMP=temp.$$
TEMP2=temp2.$$
MENSAGEM_USO="
   $(basename $0) - [OPÇÕES]

      -h --help    - Menu de ajuda
      -v --version - Versão
"
VERSAO="v2.2"
CHAVE_ORDENA=0
CHAVE_MAIUSCULO=0
CHAVE_ANO=0
VERMELHO="\033[31;1m"
VERDE="\033[32;1m"
CIANO="\033[36;1m"
# ------------------------------------------------------------------------ #

# ------------------------------- TESTES ----------------------------------------- #
[ ! -x "$(which lynx)" ]   && echo -e "${CIANO}Lynx precisa ser instalado!"   && sudo apt install lynx -y  1> /dev/null 2>&1 # Lynx instalado?
[ ! -x "$(which dialog)" ] && echo -e "${CIANO}Dialog precisa ser instalado!" && sudo apt install dialog -y 1> /dev/null 2>&1 # Dialog instalado?
# ------------------------------------------------------------------------ #

# ------------------------------- FUNÇÕES ----------------------------------------- #
VerificaAno () {
   lynx -source https://www.imdb.com/list/ls537868776/ | grep "lister-item-year" | sed 's/<span.*">//;s/<.*n>//' > $TEMP

   while read -r titulo ano; do
      echo "$titulo $ano" >> $TEMP2
   done < <(paste "$DCEU" "$TEMP")

   rm "$TEMP"
   mv "$TEMP2" "$DCEU"
}

Listar () {
   dialog --title "Filmes DCEU" --textbox "$DCEU" 20 60
}

ResetaLista () {
   lynx -source https://www.imdb.com/list/ls537868776/ | grep "img alt" | sed 's/>.*="//;s/"//' > $DCEU
}
# ------------------------------------------------------------------------ #

# ------------------------------- EXECUÇÃO ----------------------------------------- #
while test -n "$1"
do
   case "$1" in
      -h | --help)    echo -e "${CIANO}$MENSAGEM_USO" && exit 0                             ;;
      -v | --version) echo -e "${CIANO}$(basename $0 | cut -d . -f 1) $VERSAO" && exit 0    ;;
      *)              echo -e "${VERMELHO}Opção inválida, valide o -h." && exit 1           ;;
   esac
   shift
done

ResetaLista

while :
do
   menu=$(dialog --title "Lista de filmes & series do DCEU 2.2" \
                 --stdout \
                 --menu "Escolha uma das opções abaixo:" \
                 0 0 0 \
                 listar "Mostra a lista" \
                 ordenar "Ordena a lista alfabeticamente" \
                 caps "Deixa a lista em CAPS LOCK" \
                 ano "Mostra o ano que os títulos foram produzidos")
   [ $? -ne 0 ] && rm -f "$DCEU" && exit 0

   case $menu in
      listar) Listar ;;
      ordenar)   
         cat "$DCEU" | sort > "$TEMP" && mv "$TEMP" "$DCEU"
         Listar
         ResetaLista
      ;;
      caps)
         cat "$DCEU" | tr [a-z] [A-Z] > "$TEMP" && mv "$TEMP" "$DCEU"
         Listar
         ResetaLista
      ;;
      ano)
         VerificaAno
         Listar
         ResetaLista
      ;;
   esac
done
# ------------------------------------------------------------------------ #
