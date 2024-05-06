#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} F0400102    
Tela de medição dos tanques
@author Michel Sander
@since 11/07/2019
@version 1.0  
@return 
@param 
@type function     
/*/ 

User Function F0400102(aCabec, aLinha, nPosLinha, cUnidProd, nOpcMnu)

   LOCAL   aRetMed   := {}
   LOCAL   nQ        := 0

   DEFAULT aCabec    := {}
   DEFAULT aLinha    := {}
   DEFAULT nPosCols  := 0
   DEFAULT cUnidProd := ""
   DEFAULT nOpcMnu   := 0

   PRIVATE cMedAnter := "Medição Anterior"
   PRIVATE cMedAtual := "Medição Atual"
   PRIVATE cProdCiclo:= ""
   PRIVATE dData 	   := dDataBase
   PRIVATE cHora 	   := Time()
   PRIVATE cTipOper  := SPACE(02)
   PRIVATE cTextOper := ""
   PRIVATE cTanque   := SPACE(06)
   PRIVATE cDescrT   := SPACE(30)
   PRIVATE cUser     := SubStr(cUsuario,7,15)
   PRIVATE cNumOp    := Space(13)
   PRIVATE cTanDes   := Space(06)
   PRIVATE cDestDesc := Space(15)
   PRIVATE nAltAmb1  := 0
   PRIVATE nTemTan1  := 0.0
   PRIVATE nTemAmo1  := 0.0
   PRIVATE nAltH2O1  := 0.0
   PRIVATE nDenAmb1  := 0.0000
   PRIVATE nDen20C1  := 0.0000
   PRIVATE nFatCon1  := 0.0
   PRIVATE nVolAmb1  := 0.0
   PRIVATE nVolLiq1  := 0.0
   PRIVATE nMassa1   := 0.0
   PRIVATE nVolH2O1  := 0
   PRIVATE dData1    := Ctod("")
   PRIVATE cHora1    := Space(12)
   PRIVATE nAltAmb2  := 0
   PRIVATE nTemTan2  := 0.0
   PRIVATE nTemAmo2  := 0.0
   PRIVATE nAltH2O2  := 0.0
   PRIVATE nDenAmb2  := 0.0000
   PRIVATE nDen20C2  := 0.0000
   PRIVATE nFatCon2  := 0.0
   PRIVATE nVolAmb2  := 0.0
   PRIVATE nVolLiq2  := 0.0
   PRIVATE nMassa2   := 0.0
   PRIVATE nVolH2O2  := 0
   PRIVATE dData2    := dDataBase
   PRIVATE cHora2    := Time()
   PRIVATE nVarV20C  := 0.0
   PRIVATE nVarVAmb  := 0.0
   PRIVATE nVarMass  := 0.0
   PRIVATE nTotVAmb  := 0.0
   PRIVATE nTotV20C  := 0.0
   PRIVATE nTotVMass := 0.0
   PRIVATE nCapSeg   := 0.0
   PRIVATE nCapAmb   := 0.0
   PRIVATE nEspDisp  := 0.0
   PRIVATE cDescProd := Space(60)
   PRIVATE cObserv   := Space(200)
   PRIVATE cUltId    := ""
   PRIVATE cCiclo    := ""
   PRIVATE cSinal1   := ''
   PRIVATE cSinal2   := ''
   PRIVATE cSinal3   := ''
   PRIVATE cDescTpOp := ''
   PRIVATE nLin  	   := 03
   PRIVATE nCol1 	   := 02
   PRIVATE nEspDest  := 0
   PRIVATE nSegDest  := 0
   PRIVATE nSaldoPC7  := 0
   PRIVATE aSaldoPC7  := {}
   PRIVATE aFatorZZ2  := {}
   PRIVATE cDifProd   := ""
   PRIVATE nDifProd   := 0
   PRIVATE lAjustAmb  := .F.
   PRIVATE cFS_C040012:= GetMV("FS_C040012")
   PRIVATE oFontSinal := TFont():New('Arial',,28,,.T.,,,,.T.,.F.)
   PRIVATE oFontTpOp  := TFont():New('Arial',,18,,.T.,,,,.T.,.F.)
   PRIVATE oTanDes, oDestDesc, oOp, oSinal1, oSinal2, oSinal3, oDlgMed, oDescTpOp, oTextOper
   PRIVATE oGet1, oGet2, oGet3, oGet4, oGet5, oGet6, oGet7, oGet8, oGet9, oGet10
   PRIVATE oGet11,oGet12,oGet13,oGet14,oGet15,oGet16,oGet17,oGet18,oGet19,oGet20
   PRIVATE oGet21,oGet22,oGet23,oGet24,oGet25,oGet26,oGet27,oGet28,oGet29,oGet30
   PRIVATE oGet31,oGet32,oGet33,oGet34
   PRIVATE xOpcMnu := nOpcMnu
   PRIVATE lVerReceb := .T.

   // Verifica se a chamada para medição é pela rotina de movimentação dos tanques (P04050) ou ciclo de combustível (P04001)  
   If AllTrim(FunName()) == 'F0405001'
      IF !TRB->PAA_STATUS $ 'A*R*P*T'
         cErro := "Tanque não disponível para medição!"
         Help(NIL, NIL, "F0400102", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
         Return
      ENDIF
      cTanque  := TRB->PAA_TANQUE
      cDescrT  := TRB->PAA_DESCR
      nTemTan1 := TRB->PAA_TEMTAN
      nDenAmb1 := TRB->PAA_DENSID
      PAA->(dbSetOrder(1))
      PAA->(dbSeek(xFilial()+cTanque))
   ElseIf AllTrim(FunName())=='F0400100'
      // Verifica se a chamada pelo ciclo é pelo botão de Medição ou Alimentação
      If nOpcMnu == 0
         If Empty(cFS_C040012)
            cErro := "O parâmetro FS_C040012 que define o tipo de operação padrão para medição pelo ciclo não está configurado. Defina o tipo padrão no parâmetro."
            Help(NIL, NIL, "F0400102", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
            Return({})
         EndIf
         PB5->(dbSetOrder(1))
         IF !PB5->(dbSeek(xFilial("PB5")+AllTrim(cFS_C040012)))
            cErro := "Tipo de Operação padrão configurado no parâmetro FS_C040012 não existe!"
            Help(NIL, NIL, "F0400102", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
            Return ({})
         Else
            If PB5->PB5_LTUNIC == '1' .Or. PB5->PB5_MOVEST == '1' .Or. PB5->PB5_TQDEST == '1' .Or. PB5->PB5_INSPEC == '1' .Or. PB5->PB5_RATEIO == '1'
               cErro := "Tipo de Operação padrão configurado no parâmetro FS_C040012 para o ciclo de combustível, não pode movimentar estoque, rateio, lote único, transferência e ou inspeção de entrada!"
               Help(NIL, NIL, "F0400102", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
               Return ({})
            EndIf
         ENDIF
         cTipOper   := cFS_C040012
         cCiclo     := PAQ->PAQ_NCICLO
         nPosTanq   := ASCAN(aCabec, { |x| AllTrim(x[2]) == "PAR_TANQUE"})
         nPosOP     := ASCAN(aCabec, { |x| AllTrim(x[2]) == "PAR_OP"})
         nPosPro    := ASCAN(aCabec, { |x| AllTrim(x[2]) == "PAR_CODPRO"})
         cNumOp     := aLinha[nPosLinha, nPosOP]
         cProdCiclo := aLinha[nPosLinha, nPosPro]

         // Busca Tanque Origem da movimentação no ciclo de combustível
         PAA->(dbSetOrder(1))
         If PAA->(dbSeek(xFilial()+aLinha[nPosLinha, nPosTanq]))
            cTanque  := PAA->PAA_TANQUE
            cDescrT  := PAA->PAA_DESCR
            nTemTan1 := PAA->PAA_TEMTAN
            nDenAmb1 := PAA->PAA_DENSID
         ENDIF
      Else
         // Chamada pelo ciclo no botão de Alimentação
         // Seleção de tanques
      /*/ aAliment[1] = Código do Tanque
         aAliment[2] = Código do Tipo de Operação
         aAliment[3] = Botão acionado na janela (.T.) = Confirmar / (.F.) = Cancelar
      /*/
         aAliment := U_F0400121()
         If !aAliment[3] .Or. Empty(aAliment[1]) .Or. Empty(aAliment[2])
            Return({})
         EndIf

         // Busca Tanque Origem da movimentação no ciclo de combustível
         PAA->(dbSetOrder(1))
         If PAA->(dbSeek(xFilial()+aAliment[1]))
            cTanque  := PAA->PAA_TANQUE
            cDescrT  := PAA->PAA_DESCR
            nTemTan1 := PAA->PAA_TEMTAN
            nDenAmb1 := PAA->PAA_DENSID
         ENDIF
         cTipOper   := aAliment[2]
         cCiclo     := PAQ->PAQ_NCICLO

      EndIf

      //Cria arquivo temporário
      U_F0405005(cTanque)
   Endif

   // Verifica medição pendente
   If PAA->PAA_STATUS == 'M'
      cErro := "O tanque está com medição pendente. Efetive a leitura antes de prosseguir."
      Help(NIL, NIL, "F0400102", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
      If AllTrim(FunName())=='F0405001'
         Return
      Else
         RETURn({})
      EndIf
   EndIf

   // Busca o último produto disponível no tanque 
   aSaldoPC7 := U_F0407901(cTanque, .T.)
   cDifProd  := ""
   For nQ    := 1 to Len(aSaldoPC7)
      If cDifProd <> AllTrim(aSaldoPC7[nQ,1])
         cDifProd := aSaldoPC7[nQ,1]
         nDifProd++
      EndIf
   Next
   If nDifProd > 1
      Help(NIL, NIL, "F0400102", NIL, "Existem produtos distintos com saldo no tanque. Leitura não será realizada.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Deixe apenas um produto com saldo no tanque."})
      If AllTrim(FunName())=='F0405001'
         Return
      Else
         RETURn({})
      EndIf
   EndIf

   nSaldoPC7 := If(Len(aSaldoPC7) >0, aSaldoPC7[1,2], 0)
   If AllTrim(FunName())=='F0405001'
      If Empty(aSaldoPC7[1,1])
         aSaldoPC7[1,1] := U_F0400122() //Exibe tela para escolher produto
         If Empty(aSaldoPC7[1,1])
            If AllTrim(FunName())=='F0405001'
               Return
            else
               RETURn({})
            EndIf
         EndIf
         SB2->(DbSetOrder(1)) //B2_FILIAL+B2_COD+B2_LOCAL
         If !SB2->(DbSeek(FWXFilial('SB2')+AvKey(aSaldoPC7[1,1], 'B2_COD')))
            If !U_F0400124(aSaldoPC7[1,1], GetMV('MV_X_LBASE')) //ExecAuto do Saldo Inicial por armazém
               If AllTrim(FunName())=='F0405001'
                  Return
               else
                  RETURn({})
               EndIf
            EndIf
         EndIf
         PC7->(DbSetOrder(1)) //PC7_FILIAL+PC7_PRODUT+PC7_TANQUE
         If !PC7->(DbSeek(FWXFilial('PC7')+AvKey(aSaldoPC7[1,1], 'PC7_PRODUT')+AvKey(cTanque, 'PC7_TANQUE')))
            If !U_F0407714(aSaldoPC7[1,1], cTanque) //ExecAuto do Saldo inicial do Tanque
               If AllTrim(FunName())=='F0405001'
                  Return
               else
                  RETURn({})
               EndIf
            EndIf
         EndIf
      ENDIF
   Else
      // Verifica no ciclo se a chamada foi feita pelo botão de Medição
      If nOpcMnu == 0
         aSaldoPC7[1,1] := cProdCiclo
      EndIf
   EndIf

   // Busca a descrição do produto no Tanque
   cDescProd := AllTrim(aSaldoPC7[1,1])+" | "+SubStr(Posicione("SB1",1,xFilial("SB1")+aSaldoPC7[1,1],"B1_DESC"),1,45)

   // Busca o fator de conversão do produto
   aFatorZZ2 := U_F0400107(aSaldoPC7[1,1], nDenAmb1, nTemTan1, 1)
   If !aFatorZZ2[3]
      cErro := "Fator de Conversão inexistente para a densidade e temperatura cadastrada nesse tanque!"+Chr(13)+Chr(13)
      cErro += "Codigo Produto "+aSaldoPC7[1,1]+Chr(13)+Chr(13)
      Help(NIL, NIL, "F0400102", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
      If AllTrim(FunName())=='F0405001'
         Return
      else
         RETURn({})
      EndIf
   EndIf

   // Verifica os recebimentos antes de liberar leitura de tanques em status de recebimento
   If PAA->PAA_STATUS == 'R'
      MsgRun("Verificando recebimentos...","Aguarde", { || lVerReceb := U_F0400126(PAA->PAA_TANQUE, aSaldoPC7[1,1]) } )
      If !lVerReceb
         cErro := "Existe(m) nota(s) fiscal(is) de recebimento pendente(s) de classificação nesse tanque!"
         Help(NIL, NIL, "F0400102", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {"classifique o(s) documento(s) de entrada e tente novamente."})
         If AllTrim(FunName())=='F0405001'
            Return
         else
            RETURn({})
         EndIf
      EndIf
   EndIf

   // Busca a última OP apontada no tanque para status de produção
   If PAA->PAA_STATUS == 'P'
      If Empty(cNumOP)
         cNumOP := U_F0400116(aSaldoPC7[1,1], cTanque)
      EndIf
   EndIf

   // Busca a última medição do tanque escolhido
   aMediAnt := U_F0400108(@cTanque, aFatorZZ2[1], aFatorZZ2[2] )

   // Carrega os dados da medição anterior 
   nAltAmb1 := aMediAnt[1]
   nTemTan1 := If(aMediAnt[2]==0, nTemTan1, aMediAnt[2])
   nTemAmo1 := aMediAnt[3]
   nAltH2O1 := aMediAnt[4]
   nDenAmb1 := If(aMediAnt[5]==0, nDenAmb1, aMediAnt[5])
   nDen20C1 := If(aMediAnt[6]==0, aFatorZZ2[1], aMediAnt[6])
   nFatCon1 := If(aMediAnt[7]==0, aFatorZZ2[2], aMediAnt[7])
   nVolAmb1 := If(aMediAnt[8]==0, TRB->PAB_VOLAMB, aMediAnt[8])
   nVolLiq1 := If(aMediAnt[9]==0, nSaldoPC7, aMediAnt[9])
   nMassa1  := If(aMediAnt[10]==0, (TRB->PAB_VOLAMB * nDenAmb1), aMediAnt[10])
   nVolH2O1 := aMediAnt[11]
   dData1   := aMediAnt[12]
   cHora1   := aMediAnt[13]
   nDen20C2 := aFatorZZ2[1]
   nFatCon2 := aFatorZZ2[2]
   nVarV20C := 0
   nVarVAmb := 0
   nVarMass := 0
   nCapSeg  := TRB->PAA_ESPSEG
   nEspDisp := TRB->PAA_ESPDIS
   cUltId   := If(!Empty(aMediAnt[19]),Soma1(aMediAnt[19]),Soma1("0000"))
   nTemTan2 := PAA->PAA_TEMTAN

   // Se houver movimento de estoque após última leitura corrige o Saldo a 20ºC da última leitura
   If Int(Round(nSaldoPC7,2)) <> Int(nVolLiq1)
      nVolAmb1  := Round((Round(nSaldoPC7,2) / nFatCon2),2)
      lAjustAmb := .T.
   EndIf

   // Monta a janela de medições  
   DEFINE MSDIALOG oDlgMed TITLE OemToAnsi("Registro da Medição") FROM 0,0 TO 600,995 PIXEL of oMainWnd PIXEL //300,400 PIXEL of oMainWnd PIXEL

   // Cabeçalho
   @ nLin-1, nCol1	SAY oTexto01 Var 'Data'  			      SIZE 100,10 PIXEL
   oTexto01:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin-1, nCol1+57 SAY oTexto02 Var 'Hora'  			      SIZE 100,10 PIXEL
   oTexto02:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin-1, nCol1+95 SAY oTexto03 Var 'Tp Oper.'    	      SIZE 100,10 PIXEL
   oTexto03:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin-1, nCol1+125	SAY oTexto05 Var 'Usuário'  		   SIZE 100,10 PIXEL
   oTexto05:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin-1, nCol1+182 SAY oTexto06 Var 'Ordem de Produção'	SIZE 100,10 PIXEL
   oTexto06:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin-1, nCol1+250 SAY oTexto04 Var 'Tanque'			   SIZE 100,10 PIXEL
   oTexto04:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin-1, nCol1+380 SAY oTexto07 Var 'Tanque Destino'	   SIZE 100,10 PIXEL
   oTexto07:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)

   nLin += 08
   @ nLin, nCol1	   MSGET oData     VAR dData        SIZE 50,15 WHEN .F. PIXEL
   oData:oFont := TFont():New('Arial',,16,,.T.,,,,.T.,.F.)
   @ nLin, nCol1+57  MSGET oHora     VAR cHora        SIZE 30,15 WHEN .F. PIXEL
   oHora:oFont := TFont():New('Arial',,16,,.T.,,,,.T.,.F.)
   @ nLin, nCol1+95  MSGET oTipo     VAR cTipOper     SIZE 25,15 F3 "FS0450" VALID (!Empty(cTipOper) .And. VldOper()) WHEN .T. PIXEL
   oTipo:oFont := TFont():New('Arial',,16,,.T.,,,,.T.,.F.)
   @ nLin, nCol1+125 MSGET oUser     VAR cUser        SIZE 50,15 WHEN .F. PIXEL
   oUser:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin, nCol1+182 MSGET oOp       VAR cNumOp       SIZE 65,15 WHEN .F. F3 "FSSC2A" VALID VldOrdem() PIXEL
   oOp:oFont := TFont():New('Arial',,16,,.T.,,,,.T.,.F.)
   @ nLin, nCol1+250 MSGET oTanque   VAR cTanque      SIZE 45,15 WHEN .F. PIXEL
   oTanque:oFont := TFont():New('Arial',,16,,.T.,,,,.T.,.F.)
   @ nLin, nCol1+300 MSGET oDescrT   VAR cDescrT      SIZE 75,15 WHEN .F. PIXEL
   oDescrT:oFont := TFont():New('Arial',,16,,.T.,,,,.T.,.F.)
   @ nLin, nCol1+380 MSGET oTanDes   VAR cTanDes      SIZE 45,15 WHEN .F. F3 "FSPAA" VALID (!Empty(cTanDes) .And. VldTDest()) PIXEL
   oTanDes:oFont := TFont():New('Arial',,16,,.T.,,,,.T.,.F.)
   @ nLin, nCol1+430 MSGET oDestDesc VAR cDestDesc    SIZE 65,15 WHEN .F. PIXEL
   oDestDesc:oFont := TFont():New('Arial',,16,,.T.,,,,.T.,.F.)
   nLin += 25
   @ nLin-06, nCol1+95 SAY oTextID Var 'Seq. Medição'	SIZE 50,10 PIXEL
   oTextID:oFont := TFont():New('Arial',,14,,.T.,,,,.T.,.F.)
   oUltId := TSay():New(nLin-06,nCol1+140,{||cUltId},oDlgMed,,oFontTpOp,,,,.T.,CLR_RED,CLR_WHITE,400,10)

   // Primeiro e segundo box 
   @ nLin,nCol1-1   TO nLin+098, nCol1+235 LABEL cMedAnter PIXEL OF oDlgMed
   @ nLin,nCol1+245 TO nLin+171, nCol1+246 LABEL "" PIXEL OF oDlgMed
   @ nLin,nCol1+256 TO nLin+098, nCol1+490 LABEL cMedAtual PIXEL OF oDlgMed

   // Entradas de dados do PRMEIRO box (MEDIÇÃO ANTERIOR) 
   @ nLin+09,nCol1+1	 SAY oTexto11 Var 'Altura Ambiente:' SIZE 100,10 PIXEL
   oTexto11:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+06,nCol1+73 MSGET oGet1 VAR nAltAmb1 PICTURE PesqPict('PAB','PAB_REGUA') SIZE 100,10  WHEN .f. PIXEL
   oGet1:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+09,nCol1+175	 SAY omm1 Var 'mm' SIZE 10,10 PIXEL
   omm1:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+21,nCol1+1	 SAY oTexto12 Var 'Temperatura Tanque:' SIZE 100,10 PIXEL
   oTexto12:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+19, nCol1+73 MSGET oGet2 VAR nTemTan1 PICTURE PesqPict('PAB','PAB_TEMTAN') SIZE 100,10  WHEN .f. PIXEL
   oGet2:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+21,nCol1+175	 SAY omm2 Var 'ºC' SIZE 10,10 PIXEL
   omm2:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+34, nCol1+1 SAY oTexto13 Var 'Temperatura Amostra:' SIZE 100,10 PIXEL
   oTexto13:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+32, nCol1+73 MSGET oGet3 VAR nTemAmo1 PICTURE PesqPict('PAB','PAB_TEMAMO') SIZE 100,10  WHEN .f. PIXEL
   oGet3:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+32,nCol1+175	 SAY omm3 Var 'ºC' SIZE 10,10 PIXEL
   omm3:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+46,nCol1+1	 SAY oTexto14 Var 'Altura da Água:' SIZE 100,10 PIXEL
   oTexto14:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+45, nCol1+73 MSGET oGet4 VAR nAltH2O1 PICTURE PesqPict('PAB','PAB_ALAGUA') SIZE 100,10  WHEN .f. PIXEL
   oGet4:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+59, nCol1+1 SAY oTexto15 Var 'Densidade Ambiente:' SIZE 100,10 PIXEL
   oTexto15:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+58, nCol1+73 MSGET oGet5 VAR nDenAmb1 PICTURE PesqPict('PAB','PAB_DENSID') SIZE 100,10  WHEN .f. PIXEL
   oGet5:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+73,nCol1+1	 SAY oTexto16 Var 'Densidade a 20ºC:' SIZE 100,10 PIXEL
   oTexto16:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+71, nCol1+73 MSGET oGet6 VAR nDen20C1 PICTURE PesqPict('PAB','PAB_DENS20') SIZE 100,10  WHEN .f. PIXEL
   oGet6:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+86, nCol1+1 SAY oTexto17 Var 'Fator de Conversão:' SIZE 100,10 PIXEL
   oTexto17:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+84, nCol1+73 MSGET oGet7 VAR nFatCon1 PICTURE PesqPict('PAB','PAB_FATOR') SIZE 100,10 WHEN .f. PIXEL
   oGet7:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)

   // Entradas de dados do SEGUNDO box (MEDIÇÃO ATUAL) 
   @ nLin+09,nCol1+258	 SAY oTexto18 Var 'Altura Ambiente:' SIZE 100,10 PIXEL
   oTexto18:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+6, nCol1+329 MSGET oGet8 VAR nAltAmb2 PICTURE PesqPict('PAB','PAB_REGUA') SIZE 100,10 VALID { || If(nAltAmb1==0,nAltAmb1:=nAltAmb2, nAltAmb1:=nAltAmb1), If(VldRegua(), If(nDenAmb2 > 0,VldDenAmb(), .T.), .F.) } WHEN .T. PIXEL
   oGet8:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+09,nCol1+431	 SAY omm4 Var 'mm' SIZE 10,10 PIXEL
   omm4:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+21,nCol1+258	 SAY oTexto19 Var 'Temperatura Tanque:' SIZE 100,10 PIXEL
   oTexto19:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+19, nCol1+329 MSGET oGet9 VAR nTemTan2 SIZE 100,10 PICTURE PesqPict('PAB','PAB_TEMTAN') VALID { || If(nTemTan1==0,nTemTan1:=nTemTan2, nTemTan1:=nTemTan1), nTemAmo2:=nTemTan2, oGet10:Refresh(), If(nDenAmb2 > 0,VldDenAmb(), .T.) } WHEN .T. PIXEL
   oGet9:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+21,nCol1+431	 SAY omm5 Var 'ºC' SIZE 10,10 PIXEL
   omm5:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+34, nCol1+258 SAY oTexto20 Var 'Temperatura Amostra:' SIZE 100,10 PIXEL
   oTexto20:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+32, nCol1+329 MSGET oGet10 VAR nTemAmo2 SIZE 100,10 PICTURE PesqPict('PAB','PAB_TEMAMO') VALID { || If(nTemAmo1==0,nTemAmo1:=nTemAmo2, nTemAmo1:=nTemAmo1), If(nDenAmb2 > 0,VldDenAmb(), .T.) } WHEN .T. PIXEL
   oGet10:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+32,nCol1+431	 SAY omm6 Var 'ºC' SIZE 10,10 PIXEL
   omm6:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+46,nCol1+258	 SAY oTexto21 Var 'Altura da Água:' SIZE 100,10 PIXEL
   oTexto21:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+45, nCol1+329 MSGET oGet11 VAR nAltH2O2 SIZE 100,10 PICTURE PesqPict('PAB','PAB_ALAGUA') VALID { || If(nAltH2O1==0,nAltH2O1:=nAltH2O2, nAltH2O1:=nAltH2O1), VldAltH2O(), If(nDenAmb2 > 0,VldDenAmb(), .T.) } WHEN .T. PIXEL
   oGet11:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+59, nCol1+258 SAY oTexto22 Var 'Densidade Ambiente:' SIZE 100,10 PIXEL
   oTexto22:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+58, nCol1+329 MSGET oGet12 VAR nDenAmb2 SIZE 100,10 PICTURE PesqPict('PAB','PAB_DENSID') VALID { || If(nDenAmb1==0,nDenAmb1:=nDenAmb2, nDenAmb1:=nDenAmb1), VldDenAmb() } WHEN .T. PIXEL
   oGet12:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+73,nCol1+258	SAY oTexto23 Var 'Densidade a 20ºC:' SIZE 100,10 PIXEL
   oTexto23:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+71, nCol1+329 MSGET oGet13 VAR nDen20C2 PICTURE PesqPict('PAB','PAB_DENS20') SIZE 100,10  WHEN .F. PIXEL
   oGet13:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+86, nCol1+258 SAY oTexto24 Var 'Fator de Conversão:' SIZE 100,10 PIXEL
   oTexto24:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+84, nCol1+329 MSGET oGet14 VAR nFatCon2 PICTURE PesqPict('PAB','PAB_FATOR') SIZE 100,10  WHEN .F. PIXEL
   oGet14:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)

   // TERCEIRO e QUARTO box
   nLin += 100
   @ nLin,nCol1-1   TO nLin+081, nCol1+235 LABEL "" PIXEL OF oDlgMed
   @ nLin,nCol1+256 TO nLin+081, nCol1+490 LABEL "" PIXEL OF oDlgMed

   nLin -= 004
   // Entradas de dados do TERCEIRO box (MEDIÇÃO ANTERIOR)
   @ nLin+09,nCol1+1	 SAY oTexto25 Var 'Volume Ambiente:' SIZE 100,10 PIXEL
   oTexto25:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+06, nCol1+73 MSGET oGet15 VAR nVolAmb1 PICTURE PesqPict('PAB','PAB_VPROAB') SIZE 100,10  WHEN .f. PIXEL
   oGet15:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+09,nCol1+175	 SAY omm7 Var 'L' SIZE 10,10 PIXEL
   omm7:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+21,nCol1+1	 SAY oTexto26 Var 'Volume Liquido 20ºC' SIZE 100,10 PIXEL
   oTexto26:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+19, nCol1+73 MSGET oGet16 VAR nVolLiq1 PICTURE PesqPict('PAB','PAB_VPRO20') SIZE 100,10  WHEN .f. PIXEL
   oGet16:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+21,nCol1+175	 SAY omm8 Var 'L' SIZE 10,10 PIXEL
   omm8:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+34, nCol1+1 SAY oTexto27 Var 'Massa:' SIZE 100,10 PIXEL
   oTexto27:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+32, nCol1+73 MSGET oGet17 VAR nMassa1 PICTURE PesqPict('PAB','PAB_MASSA') SIZE 100,10  WHEN .f. PIXEL
   oGet17:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+33,nCol1+175	 SAY omm9 Var 'KG' SIZE 10,10 PIXEL
   omm9:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+46,nCol1+1 SAY oTexto28 Var 'Volume da Água:' SIZE 100,10 PIXEL
   oTexto28:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+45, nCol1+73 MSGET oGet18 VAR nVolH2O1 PICTURE PesqPict('PAB','PAB_VOAGUA') SIZE 100,10  WHEN .f. PIXEL
   oGet18:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+46,nCol1+175	 SAY omm10 Var 'L' SIZE 10,10 PIXEL
   omm10:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+59, nCol1+1 SAY oTexto29 Var 'Data da Medição:' SIZE 100,10 PIXEL
   oTexto29:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+58, nCol1+73 MSGET oGet19 VAR dData1 SIZE 100,10  WHEN .f. PIXEL
   oGet19:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+72,nCol1+1	 SAY oTexto30 Var 'Hora da Medição:' SIZE 100,10 PIXEL
   oTexto30:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+71, nCol1+73 MSGET oGet20 VAR cHora1 PICTURE PesqPict('PAB','PAB_HORLEI')SIZE 100,10  WHEN .f. PIXEL
   oGet20:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)

   // Entradas de dados do QUARTO box (MEDIÇÃO ATUAL)
   @ nLin+09,nCol1+258	 SAY oTexto31 Var 'Volume Ambiente:' SIZE 100,10 PIXEL
   oTexto31:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+06, nCol1+329 MSGET oGet21 VAR nVolAmb2 PICTURE PesqPict('PAB','PAB_VPROAB') SIZE 100,10  WHEN .f. PIXEL
   oGet21:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+09,nCol1+431	 SAY omm11 Var 'L' SIZE 10,10 PIXEL
   omm11:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+21,nCol1+258	 SAY oTexto32 Var 'Volume Liquido 20ºC' SIZE 100,10 PIXEL
   oTexto32:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+19, nCol1+329 MSGET oGet22 VAR nVolLiq2 PICTURE PesqPict('PAB','PAB_VPRO20') SIZE 100,10  WHEN .f. PIXEL
   oGet22:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+21,nCol1+431	 SAY omm12 Var 'L' SIZE 10,10 PIXEL
   omm12:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+34, nCol1+258 SAY oTexto33 Var 'Massa:' SIZE 100,10 PIXEL
   oTexto33:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+32, nCol1+329 MSGET oGet23 VAR nMassa2 PICTURE PesqPict('PAB','PAB_MASSA') SIZE 100,10  WHEN .f. PIXEL
   oGet23:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+33,nCol1+431	 SAY omm13 Var 'KG' SIZE 10,10 PIXEL
   omm13:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+46,nCol1+258	 SAY oTexto34 Var 'Volume da Água:' SIZE 100,10 PIXEL
   oTexto34:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+45, nCol1+329 MSGET oGet24 VAR nVolH2O2 PICTURE PesqPict('PAB','PAB_VOAGUA') SIZE 100,10  WHEN .f. PIXEL
   oGet24:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+46,nCol1+431	 SAY omm14 Var 'L' SIZE 10,10 PIXEL
   omm14:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+59, nCol1+258 SAY oTexto35 Var 'Data da Medição:' SIZE 100,10 PIXEL
   oTexto35:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+58, nCol1+329 MSGET oGet25 VAR dData2 SIZE 100,10  WHEN .f. PIXEL
   oGet25:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+72,nCol1+258	 SAY oTexto36 Var 'Hora da Medição:' SIZE 100,10 PIXEL
   oTexto36:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+71, nCol1+329 MSGET oGet26 VAR cHora2 PICTURE PesqPict('PAB','PAB_HORLEI') SIZE 100,10  WHEN .f. PIXEL
   oGet26:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   nLin += 085

   // Box do Resultado
   @ nLin,nCol1-1 TO nLin+054, nCol1+490 LABEL "Resultado da Movimentação" PIXEL OF oDlgMed
   nLIn += 7

   @ nLin+2,nCol1+1 SAY oTexto39 Var 'Saldo em Ambiente:' SIZE 100,10 PIXEL
   oTexto39:oFont := TFont():New('Arial',,16,,.T.,,,,.T.,.F.)
   @ nLin,nCol1+80 MSGET oGet29 VAR Int(nCapAmb) PICTURE PesqPict('PAB','PAB_VPROAB') SIZE 100,10  WHEN .f. PIXEL
   oGet29:oFont := TFont():New('Arial',,16,,.T.,,,,.T.,.F.)
   @ nLin+2,nCol1+185 SAY omm17 Var 'L' SIZE 25,10 PIXEL
   omm17:oFont := TFont():New('Arial',,16,,.T.,,,,.T.,.F.)

   @ nLin+2,nCol1+255 SAY oTexto38 Var 'Variação Volume Amb.:' SIZE 100,10 PIXEL
   oTexto38:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   oSinal2 := TSay():New(nLin,nCol1+323,{||cSinal2},oDlgMed,,oFontSinal,,,,.T.,CLR_GREEN,CLR_WHITE,10,10)
   @ nLin, nCol1+331 MSGET oGet28 VAR nVarVAmb PICTURE PesqPict('PAB','PAB_VARVAB') SIZE 100,10  WHEN .f. PIXEL
   oGet28:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+2,nCol1+435 SAY omm16 Var 'L' SIZE 25,10 PIXEL
   omm16:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   nLin += 15

   @ nLin+2,nCol1+1   SAY oTexto42 Var 'Saldo em Estoque 20ºC:' SIZE 100,10 PIXEL
   oTexto42:oFont := TFont():New('Arial',,16,,.T.,,,,.T.,.F.)
   @ nLin,nCol1+80 MSGET oGet33 VAR Int(nSaldoPC7) PICTURE PesqPict('PAB','PAB_VPROAB') SIZE 100,10  WHEN .f. PIXEL
   oGet33:oFont := TFont():New('Arial',,16,,.T.,,,,.T.,.F.)
   @ nLin+2,nCol1+185 SAY omm19 Var 'L 20ºC' SIZE 25,10 PIXEL
   omm19:oFont := TFont():New('Arial',,16,,.T.,,,,.T.,.F.)

   @ nLin+2,nCol1+255 SAY oTexto37 Var 'Variação Volume 20ºC:' SIZE 100,10 PIXEL
   oTexto37:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   oSinal1 := TSay():New(nLin,nCol1+323,{||cSinal1},oDlgMed,,oFontSinal,,,,.T.,CLR_GREEN,CLR_WHITE,10,10)
   @ nLin, nCol1+331 MSGET oGet27 VAR nVarV20C PICTURE PesqPict('PAB','PAB_VARV20') SIZE 100,10  WHEN .f. PIXEL
   oGet27:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+2,nCol1+435 SAY omm15 Var 'L 20ºC' SIZE 35,10 PIXEL
   omm15:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   nLin += 15

   @ nLin+2,nCol1+1 SAY oTexto40 Var 'Espaço Disponível:' SIZE 100,10 PIXEL
   oTexto40:oFont := TFont():New('Arial',,16,,.T.,,,,.T.,.F.)
   @ nLin, nCol1+80 MSGET oGet30 VAR Int(nEspDisp) PICTURE PesqPict('PAB','PAB_VPROAB') SIZE 100,10  WHEN .f. PIXEL
   oGet30:oFont := TFont():New('Arial',,16,,.T.,,,,.T.,.F.)
   @ nLin+2,nCol1+185 SAY omm18 Var 'L' SIZE 25,10 PIXEL
   omm18:oFont := TFont():New('Arial',,16,,.T.,,,,.T.,.F.)

   @ nLin+2,nCol1+255 SAY oTexto41 Var 'Variação Massa:' SIZE 100,10 PIXEL
   oTexto41:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   oSinal3 := TSay():New(nLin,nCol1+323,{||cSinal3},oDlgMed,,oFontSinal,,,,.T.,CLR_GREEN,CLR_WHITE,10,10)
   @ nLin,nCol1+331 MSGET oGet31 VAR nVarMass PICTURE PesqPict('PAB','PAB_VARMAS') SIZE 100,10  WHEN .f. PIXEL
   oGet31:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+2,nCol1+435 SAY omm30 Var 'KG' SIZE 25,10 PIXEL
   omm30:oFont := TFont():New('Arial',,16,,.T.,,,,.T.,.F.)

   nLin += 15

   @ nLin+6,nCol1+01 SAY oTexto51 Var 'Produto:' SIZE 50,10 PIXEL
   oTexto51:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+4,nCol1+46 MSGET oGet34 VAR cDescProd SIZE 170,10  WHEN .F. PIXEL
   oGet34:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+6,nCol1+225 SAY oTextOper Var cTextOper SIZE 50,10 PIXEL
   oTextOper:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   //@ nLin+4,nCol1+205 MSGET oDescTpOp VAR cDescTpOp SIZE 140,10  WHEN .F. PIXEL
   oDescTpOp := TSay():New(nLin+6,nCol1+265,{||cDescTpOp},oDlgMed,,oFontTpOp,,,,.T.,CLR_RED,CLR_WHITE,400,10)

   nLin += 15

   @ nLin+6,nCol1+01 SAY oTexto50 Var 'Observações:' SIZE 50,10 PIXEL
   oTexto50:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nLin+3,nCol1+46 MSGET oGet32 VAR cObserv SIZE 315,10  WHEN .T. PIXEL
   oGet32:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   nLin -= 11

   // botões de controle
   @ nLin, nCol1+410 BUTTON oConfirmar   PROMPT "Confirmar"      ACTION Processa( {|| aRetMed := GravaPAB(), oDlgMed:End() } ) SIZE 080,12 PIXEL OF oDlgMed
   nLin += 14
   @ nLin, nCol1+410 BUTTON oCancelar    PROMPT "Cancelar"		  ACTION Processa( If(MsgYesNo("Deseja realmente cancelar a operação?","Cancelamento"),;
      { || aRetMed := {},         oDlgMed:End() },;
      { ||.T. } ) ) SIZE 080,12 PIXEL OF oDlgMed

   ACTIVATE MSDIALOG oDlgMed CENTER

Return ( aRetMed )

/*/{Protheus.doc} VldOper
Validação do campo Tipo de Operação (cTipOper)
@author Michel Sander
@since 26/08/2019
@version 1.0
/*/

Static Function VldOper()

   LOCAL cForPad := SuperGetMv("FS_C040501",.F.,"")
   LOCAL cLojPad := SuperGetMv("FS_C040502",.F.,"")
   LOCAL cA5Fields := ""

   If AllTrim(FunName())=='F0400100'
      If xOpcMnu == 0
         If AllTrim(cTipOper) <> AllTrim(cFS_C040012)
            cErro := "Tipo de Operação digitado difere do tipo padrão no parâmetro FS_C040012"
            Help(NIL, NIL, "F0400102", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
            Return (.F.)
         EndIf
      EndIf
   EndIf

   PB5->(dbSetOrder(1))
   IF !PB5->(dbSeek(xFilial("PB5")+cTipOper))
      cErro := "Tipo de Operação inválido!"
      Help(NIL, NIL, "F0400102", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
      Return (.F.)
   ENDIF

   If PB5->PB5_ORDPRO=='1'
      If PB5->PB5_TQDEST=='1'
         oTandes:oGet:bWhen := { || .T. }
         If xOpcMnu <> 0
            cTanDes := PAQ->PAQ_TANQUE
            oTanDes:Refresh()
         EndIf
      Else
         oTandes:oGet:bWhen := { || .F. }
      Endif
      If Empty(cNumOp)
         oOp:oGet:bWhen := { || .T. }
         oOp:Refresh()
         oOp:SetFocus()
      EndIf
   Else
      If PB5->PB5_TQDEST=='1'
         oTandes:oGet:bWhen := { || .T. }
         If xOpcMnu <> 0
            cTanDes := PAQ->PAQ_TANQUE
         EndIf
         oTandes:Refresh()
         oTandes:SetFocus()
      Else
         oTandes:oGet:bWhen := { || .F. }
      Endif
      oOp:oGet:bWhen := { || .F. }
   Endif

   IF !PB5->PB5_ATIVA=='1'
      cErro := "O tipo de operação não está ativa!"
      Help(NIL, NIL, "F0400102- VldOper()", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
      Return (.F.)
   ENDIF

   IF PB5->PB5_INSPEC == "1"
      If Empty(cForPad)
         cErro := "Código de Fornecedor padrão para gerar inspeção de entrada não encontrado no parâmetro FS_C040501"
         Help(NIL, NIL, "F0400102- VldOper()", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
         Return (.F.)
      EndIf
      If Empty(cLojPad)
         cErro := "Loja do Fornecedor padrão para gerar inspeção de entrada não encontrado no parâmetro FS_C040502"
         Help(NIL, NIL, "F0400102- VldOper()", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
         Return (.F.)
      EndIf
      SA5->(dbSetOrder(1))
      If !SA5->(dbSeek(xFilial()+cForPad+cLojPad+aSaldoPC7[1,1]))
         cErro := "Amarração Produto x Fornecedor não cadastrada para o produto "+aSaldoPC7[1,1]+" na Inspeção de Entrada!"
         Help(NIL, NIL, "F0400102- VldOper()", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
         Return (.F.)
      Else
         cA5Fields := ""
         If AllTrim(SA5->A5_SITU) == 'C' .Or. Empty(SA5->A5_SITU)
            cErro := "Verifique no módulo de inspeção de entrada, no cadastro de amarração produto x fornecedor, o preenchimento do campo SITUAÇÃO que deve ser diferente de C e/ou não pode estar em branco:"+CRLF+CRLF
            Help(NIL, NIL, "F0400102- VldOper()", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
            Return (.F.)
         EndIf
         If Empty(SA5->A5_SITU)
            cA5Fields += "Campo A5_SITU (Situação) em branco"+CRLF
         EndIf
         If SA5->A5_TEMPLIM == 0
            cA5Fields += "Campo A5_TEMPLIN (Tempo Limite) zerado"+CRLF
         EndIf
         If Empty(SA5->A5_FABREV)
            cA5Fields += "Campo A5_FABREV (Fab/Rev/Perm) em branco"+CRLF
         EndIf
         If Empty(SA5->A5_ATUAL)
            cA5Fields += "Campo A5_ATUAL (Atualiza) em branco"+CRLF
         EndIf
         If Empty(SA5->A5_TIPATU)
            cA5Fields += "Campo A5_TIPATU (Tipo Atualiz) em branco"+CRLF
         EndIf
         If !Empty(cA5Fields)
            cErro := "Verifique no módulo de inspeção de entrada, os seguintes campos no cadastro de amarração produto x fornecedor:"+CRLF+CRLF
            cErro += cA5Fields
            Help(NIL, NIL, "F0400102- VldOper()", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
            Return (.F.)
         EndIf
      EndIf
      QE6->(dbSetOrder(1))
      If !QE6->(dbSeek(xFilial()+aSaldoPC7[1,1]))
         cErro := "Especificação técnica do produto "+aSaldoPC7[1,1]+" não cadastrada no módulo de inspeção."
         Help(NIL, NIL, "F0400102- VldOper()", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
         Return (.F.)
      EndIf
   EndIf

   If TRB->PAA_STATUS == 'R'
      IF PB5->PB5_LIBTQ =='1'
         cErro := "Tipo de operação não permitida para o status atual do tanque!"
         Help(NIL, NIL, "F0400102- VldOper()", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
         Return (.F.)
      ENDIF
   EndIf

   IF TRB->PAA_STATUS == 'T'
      IF PB5->PB5_LIBTQ=='1' .And. PB5->PB5_INSPEC=='1'
         cErro := "Tipo de operação que libera o tanque, não pode ser utilizada quando o mesmo tipo prevê inspeção de entrada!"
         Help(NIL, NIL, "F0400102- VldOper()", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
         Return (.F.)
      ENDIF
   ENDIF

   cDescTpOp := SubStr(PB5->PB5_DESCR,1,35)
   cTextOper := 'Operação:'
   oTextOper:Refresh()
   oDescTpOp:Refresh()

Return ( .T. )

/*/{Protheus.doc} VldOrdem 
Validação do campo Número da OP (cNumOp)
@author Michel Sander
@since 26/08/2019
@version 1.0
/*/

Static Function VldOrdem()

   IF Empty(cNumOp) .And. PB5->PB5_ORDPRO=='1'
      cErro := "Digitação da ordem de produção obrigatória!"
      Help(NIL, NIL, "F0400102- VldOrdem()", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
      Return (.F.)
   ENDIF

   SC2->(dbSetOrder(1))
   IF !SC2->(dbSeek(xFilial("SC2")+AllTrim(cNumOP)))
      cErro := "Ordem de produção inválida!"
      Help(NIL, NIL, "F0400102- VldOrdem()", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
      Return (.F.)
   ENDIF

   IF !Empty(SC2->C2_DATRF)
      cErro := "Ordem de produção encerrada!"
      Help(NIL, NIL, "F0400102- VldOrdem()", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
      Return (.F.)
   ENDIF

Return ( .T. )

/*/{Protheus.doc} VldTDest (cTanDes)
Validação do campo Tanque Destino
@author Michel Sander
@since 26/08/2019
@version 1.0
/*/

Static Function VldTDest()

   LOCAL lVldRet := .T.
   LOCAL cSavePAA := PAA->(GetArea())

   If Empty(cTanDes)
      Return ( lVldRet )
   ENDIF

   PAA->(dbSetOrder(1))
   If !PAA->(dbSeek(xFilial("PAA")+AllTrim(cTanDes)))
      cErro := "Tanque destino inválido!"
      Help(NIL, NIL, "F0400102- VldTDest()", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
      lVldRet := .F.
   EndIf
   IF !PAA->PAA_STATUS == 'P' .And. PB5->PB5_ORDPRO == "1"
      cErro := "Status atual do tanque não permite ordem de produção para esse tipo de operação!"
      Help(NIL, NIL, "F0400102- VldTDest()", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
      lVldRet := .F.
   ENDIF

   If lVldRet
      cDestDesc := PAA->PAA_DESCR
      oDestDesc:Refresh()
   EndIf

   PAA->(RestArea(cSavePAA))

Return (.T.)

/*/{Protheus.doc} VldRegua (cAltAmb2)
Validação do campo Altura do Ambiente
@author Michel Sander
@since 26/08/2019
@version 1.0 
/*/

Static Function VldRegua()

   LOCAL lRegua    := .T.
   LOCAL nTamRegua := 0
   LOCAL cReguaCM  := ""
   LOCAL cReguaMM  := ""
   LOCAL aReguas   := {}

   If nAltAmb2 == 0
      Return(.T.)
   EndIf

   nTamRegua := Len(AllTrim(Str(nAltAmb2)))-1
   cReguaCM  := SUBSTR(AllTrim(Str(nAltAmb2)), 1, nTamRegua)
   cReguaMM  := SUBSTR(AllTrim(Str(nAltAmb2)), nTamRegua+1, 1)

   // Busca Volume nas Reguas CM e MM
   aReguas := U_F0400114(cTanque, cReguaCM, cReguaMM)

   If aReguas[1] == 0 .And. !aReguas[2]
      cErro := "Regua CM não localizada nessa altura!"
      Help(NIL, NIL, "F0400102", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
      Return (.F.)
   ENDIF
   If aReguas[3] == 0 .And. !aReguas[4]
      cErro := "Regua MM não localizada nessa altura!"
      Help(NIL, NIL, "F0400102", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
      Return (.F.)
   ENDIF

   //Atualiza VOLUME AMBIENTE
   nVolAmb2 := aReguas[1] + aReguas[3]
   If nVolAmb1 == 0
      nVolAmb1 := nVolAmb2
   EndIf

   nCapSeg  := TRB->PAA_ESPSEG
   nEspDisp := TRB->PAA_ESPDIS
   oGet29:Refresh()
   oGet30:Refresh()

Return ( lRegua )

/*/{Protheus.doc} VldAltH2O (cAltH2O2) 
Validação do campo Altura da Agua
@author Michel Sander
@since 26/08/2019
@version 1.0
/*/

Static Function VldAltH2O()

   LOCAL nTamRegua := 0
   LOCAL cReguaCM  := ""
   LOCAL cReguaMM  := ""
   LOCAL aReguas   := {}
   LOCAL nOnlyMM   := 0

   If nAltH2O2 == 0
      nVolH2O2 := 0
      oGet24:Refresh()
      Return(.T.)
   EndIf

   nTamRegua := Len(AllTrim(Str(nAltH2O2)))-1
   nOnlyMM   := Len(AllTrim(Str(nAltH2O2)))     // Usado se a altura pedir apenas MM
   cReguaCM  := SUBSTR(AllTrim(Str(nAltH2O2)), 1, nTamRegua)
   cReguaMM  := SUBSTR(AllTrim(Str(nAltH2O2)), nTamRegua+1, 1)

   // Busca Volume nas Reguas CM e MM
   aReguas := U_F0400114(cTanque, cReguaCM, cReguaMM)

   If nOnlyMM <> 1
      If aReguas[1] == 0 .And. !aReguas[2]
         cErro := "Regua CM não localizada nessa altura!"
         Help(NIL, NIL, "F0400102- VldAltH2O()", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
         Return (.F.)
      ENDIF

      If aReguas[3] == 0 .And. !aReguas[4]
         cErro := "Regua MM não localizada nessa altura!"
         Help(NIL, NIL, "F0400102- VldAltH2O()", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
         Return (.F.)
      ENDIF
   else
      If aReguas[3] == 0 .And. !aReguas[4]
         cErro := "Regua MM não localizada nessa altura!"
         Help(NIL, NIL, "F0400102- VldAltH2O()", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
         Return (.F.)
      ENDIF
   EndIf

   //Atualiza VOLUME DA AGUA
   If nOnlyMM <> 1
      nVolH2O2 := aReguas[1] + aReguas[3]
   Else
      nVolH2O2 := aReguas[3]
   EndIf
   If nVolH2O1 == 0
      nVolH2O1 := nVolH2O2
   EndIf

   oGet24:Refresh()

Return

/*/{Protheus.doc} VldDenAmb (nDenAmb2)
Validação do campo Altura do Ambiente
@author Michel Sander
@since 26/08/2019
@version 1.0
/*/

Static Function VldDenAmb()

   LOCAL lDenAmb := .T.
   LOCAL aVolAux1  := {}
   LOCAL aVolAux2  := {}
   LOCAL nIndBusca := 0

   If nDenAmb2 == 0
      Return(.T.)
   EndIf

   // Busca Densidade e Temperatura para resgatar fator de conversão
   nIndBusca := 1
   aVolAux1  := U_F0400107(aSaldoPC7[1,1], nDenAmb2 , nTemAmo2, nIndBusca)
   If !aVolAux1[3]
      cErro := "Não encontrado fator de conversão para Densidade "+Str(nDenAmb2,6,4)+ " e Temperatura da Amostra"+Str(nTemTan2,5,1)+CRLF+CRLF
      cErro += "Para o Produto "+aSaldoPC7[1,1]
      Help(NIL, NIL, "F0400102- VldDenAmb()", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
      Return (.F.)
   EndIf

   // Busca Densidade a 20ºC e Temperatura para resgatar fator de conversão
   nIndBusca := 2
   aVolAux2  := U_F0400107(aSaldoPC7[1,1], aVolAux1[1], nTemTan2, nIndBusca)
   If !aVolAux2[3]
      cErro := "Não encontrado fator de conversão para Densidade a 20ºC "+Str(aVolAux1[1],6,4)+ " e Temperatura do Tanque"+Str(nTemAmo2,5,1)+CRLF+CRLF
      cErro += "Para o Produto "+aSaldoPC7[1,1]
      Help(NIL, NIL, "F0400102- VldDenAmb()", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
      Return (.F.)
   EndIf

   //Atualiza Densidade a 20ºC e Fator de Conversão para medial atual
   nDen20C2 := aVolAux2[1]
   nFatCon2 := aVolAux2[2]

   nCapAmb  := nVolAmb1

   oGet29:Refresh()
   oGet13:Refresh()
   oGet14:Refresh()

   //Atualiza VOLUME LIQ 20º
   nVolLiq2 := nVolAmb2 * aVolAux2[2]

   //Atualiza MASSA
   nMassa2 := nVolLiq2 * nDen20C2
   If nMassa1 == 0
      nMassa1 := nMassa2
   EndIf

   //Calcula Resultados da medição - Variação Volume a 20ºC nSaldoPC7
   nVarV20C := nSaldoPC7 - nVolLiq2
   nTotV20C := nVarV20C

   //Calcula Resultados da medição - Variação Volume Ambiente
   If lAjustAmb
      nVarVAmb := nCapAmb  - nVolAmb2  //nVolAmb2 - (nSaldoPC7 / nDen20C2)
   Else
      nVarVAmb := nVolAmb1 - nVolAmb2
   EndIf
   nTotVAmb := nVarVAmb

   //Calcula Resultados da medição - Variação Massa
   nVarMass := nVarV20C * nDen20C2
   nTotVMass := nVarMass

   nCapSeg  := TRB->PAA_ESPSEG            //TRB->PAA_ESPSEG - nVolAmb2
   nEspDisp := TRB->PAA_ESPSEG - nVolAmb2 //TRB->PAA_ESPSEG - nVolLiq2

   //Atualiza Resultados da Movimentação
   If nVarV20C >= 0
      cSinal1 := "-"
      oSinal1:nClrText := 255       // Vermelho
      oSinal1:Refresh()
   Else
      cSinal1 := "+"
      oSinal1:nClrText := 32768     // Verde
      oSinal1:Refresh()
   EndIf

   If nVarVAmb >= 0
      cSinal2 := "-"
      oSinal2:nClrText := 255       // Vermelho
      oSinal2:Refresh()
   Else
      cSinal2 := "+"
      oSinal2:nClrText := 32768     // Verde
      oSinal2:Refresh()
   EndIf

   If nVarMass >= 0
      cSinal3 := "-"
      oSinal3:nClrText := 255       // Vermelho
      oSinal3:Refresh()
   Else
      cSinal3 := "+"
      oSinal3:nClrText := 32768     // Verde
      oSinal3:Refresh()
   EndIf

   //Calcula valor absoluto para apresentação das variações
   nVarV20C := Abs(nVarV20C)
   nVarVAmb := Abs(nVarVAmb)
   nVarMass := Abs(nVarMass)

   //Atualiza janela de resultados
   oGet21:Refresh()
   oGet22:Refresh()
   oGet23:Refresh()
   oGet24:Refresh()
   oGet25:Refresh()
   oGet26:Refresh()
   oGet27:Refresh()
   oGet28:Refresh()
   oGet29:Refresh()
   oGet30:Refresh()
   oGet31:Refresh()

Return ( lDenAmb )

/*/{Protheus.doc} GravaPAB
Gravação dos dados da medição
@author Michel Sander
@since 26/08/2019
@version 1.0
/*/

Static Function GravaPAB()

   LOCAL aRetMed  := {}
   LOCAL cTextMed :=""
   Local lTransac := .T.

   If !MsgYesNo("Confirma os dados da medição atual?","Gravação")
      //Recria o temporário para recompor as colunas do browse
      If AllTrim(FunName())=='F0405001'
         //Recria arquivo temporário
         MsgRun("Re-criando browse","Aguarde",{ || U_F0405005() })
         oBrwMed:Refresh()
      ENDIF
      Return ( aRetMed )
   EndIf

   If Empty(cTipOper)
      cErro := "O tipo de operação não está preenchido. A medição será desconsiderada!"
      Help(NIL, NIL, "F0400102- GravaPAB()", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
      Return ( aRetMed )
   EndIf

   If PB5->PB5_TQDEST=='1' .And. Empty(cTanDes)
      cErro := "O tipo de operação exije tanque destino. O Tanque destino não foi preenchido!"
      Help(NIL, NIL, "F0400102- GravaPAB()", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
      Return ( aRetMed )
   EndIf

   If PB5->PB5_TQDEST == '1' .And. nTotV20C < 0
      cErro := "Na operação de transferência, somente é possível diminuir o saldo do Tanque de origem."
      Help(NIL, NIL, "F0400102- GravaPAB()", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
      Return ( aRetMed )
   EndIf

   nEspDest  := 0
   nSegDest  := 0

   If !PB5->PB5_TQDEST=='1'

      If nEspDisp < 0
         cErro := "O Tanque atingiu a capacidade máxima informada na medição! A medição será desconsiderada."+CRLF+CRLF
         cErro += "Espaço de Segurança = "+TransForm(nCapSeg,"@E 999,999,999.99")+CRLF
         cErro += "Espaço Disponível   = "+TransForm(nEspDisp,"@E 999,999,999.99")+CRLF
         cErro += "Valor de Variação   = "+TransForm(Abs(nSaldoPC7 - nVolLiq2),"@E 999,999,999.99")
         Help(NIL, NIL, "F0400102- GravaPAB()", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
         RETURN ( aRetMed )
      EndIf

      If nVolAmb2 > nCapSeg
         cErro := "O Tanque atingiu a capacidade informada no arqueamento!"
         Help(NIL, NIL, "F0400102- GravaPAB()", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
      ENDIF

   EndIf

   Begin Transaction

      PAA->(dbSetOrder(1))
      PAA->(dbSeek(xFilial()+cTanque))

      Reclock("PAB",.T.)
      PAB->PAB_FILIAL := FWXFilial("PAB")
      PAB->PAB_TANQUE := cTanque
      PAB->PAB_ID     := cUltId
      PAB->PAB_DATLEI := dData2
      PAB->PAB_HORLEI := cHora2
      PAB->PAB_TIPOPE := cTipOper
      PAB->PAB_NCICLO := cCiclo
      PAB->PAB_REGUA  := nAltAmb2
      PAB->PAB_TEMTAN := nTemTan2
      PAB->PAB_TEMAMO := nTemAmo2
      PAB->PAB_DENSID := nDenAmb2
      PAB->PAB_DENS20 := nDen20C2
      PAB->PAB_FATOR  := nFatCon2
      PAB->PAB_VPROAB := nVolAmb2
      PAB->PAB_VPRO20 := nVolLiq2
      PAB->PAB_MASSA  := nMassa2
      PAB->PAB_VOAGUA := nVolH2O2
      PAB->PAB_VARV20 := nTotV20C
      PAB->PAB_VARVAB := nTotVAmb
      PAB->PAB_VARMAS := nTotVMass
      PAB->PAB_ESPSEG := nCapSeg
      PAB->PAB_ESPDIS := nEspDisp
      PAB->PAB_USUARI := cUser
      PAB->PAB_OBS    := cObserv
      PAB->PAB_D3NUMS := ""
      PAB->PAB_TM     := ""
      PAB->PAB_OP     := cNumOp
      PAB->PAB_TANDES := cTanDes
      PAB->PAB_DESCRD := cDestDesc
      PAB->PAB_ALAGUA := nAltH2O2
      PAB->PAB_EFMOVT := PB5->PB5_EFMOVT
      PAB->PAB_MOVEST := PB5->PB5_MOVEST
      PAB->PAB_PRODUT := aSaldoPC7[1,1]
      PAB->PAB_LOTE   := PAA->PAA_PRXLOT
      PAB->PAA_ULSTAT := PAA->PAA_STATUS
      PAB->(MsUnlock())

      If AllTrim(FunName())=="F0400100"
         If xOpcMnu == 0
            AADD( aRetMed, PAB->PAB_REGUA )           // Altura
            AADD( aRetMed, PAB->PAB_TEMTAN )          // Temperatura do Tanque
            AADD( aRetMed, PAB->PAB_TEMAMO )          // Temperatura da Amostra
            AADD( aRetMed, PAB->PAB_DENSID )          // Densidade Ambiente
            AADD( aRetMed, PAB->PAB_DENS20 )          // Densidade 20ºC
            AADD( aRetMed, PAB->PAB_FATOR )           // Fator de Conversão
            AADD( aRetMed, PAB->PAB_VPROAB )          // Volume Ambiente
            AADD( aRetMed, Abs(PAB->PAB_VARV20) )     // Var. Volume 20ºC
            AADD( aRetMed, PAB->PAB_OP )              // Número da OP
            AADD( aRetMed, AllTrim(GetMv("MV_X_LBASE"))) // Armazem Padrão
         Else
            aRetMed  := {}
         EndIf
      Endif

      // Mantém efetivação pendente para ser feito de forma manual
      If PAB->PAB_EFMOVT =='M'
         Reclock("PAA",.F.)
         PAA->PAA_STATUS := "M"
         PAA->(MsUnlock())
         cDescTpOp := ""
         cTextOper := ""
         oTextOper:Refresh()
         oDescTpOp:Refresh()
         lTransac := .F.
      Else
         lTransac := .T.
      ENDIF

      If lTransac
         //Efetiva Medição de acordo com tipo de operação automática
         cTextMed := If(PAA->PAA_STATUS == 'T',"Confirma Transf.","Efetivando medições")
         MsgRun(cTextMed,"Aguarde", {|| lRet := U_F0405006(PAB->PAB_FILIAL, PAB->PAB_TANQUE, PAB->PAB_ID, PAB->PAB_TIPOPE) } )
         If AllTrim(FunName())=="F0400100"
            aSaldoMat := U_F0400106(PAQ->PAQ_TANQUE, PAQ->PAQ_CODPRO, .F.)
            Reclock("PAQ",.F.)
            PAQ->PAQ_QUANT := aSaldoMat[2]
            PAQ->(MsUnlock())
         EndIf
         cDescTpOp := ""
         cTextOper := ""
         oTextOper:Refresh()
         oDescTpOp:Refresh()
      EndIf

   End Transaction
   //Recria o temporário para recompor as colunas do browse
   If AllTrim(FunName())=='F0405001'
      //Recria arquivo temporário
      MsgRun("Re-criando browse","Aguarde",{ || U_F0405005() })
      oBrwMed:Refresh()
   EndIf

Return ( aRetMed )

/*/{Protheus.doc} F0400106 
Busca o último produto disponível no tanque 
@author Michel Sander
@since 26/08/2019
@version 1.0
/*/

User Function F0400106(cTanque, cProdUso, lVerSaldo)

   LOCAL   aRet      := {}
   LOCAL   cWherePC7 := ""
   DEFAULT cProdUso  := ""
   DEFAULT lVerSaldo := .T.

   // Busca o último produto no tanque escolhido
   cAliasPC7 := GetNextAlias()
   If !Empty(cProdUso)
      cWherePC7 := "%PC7.PC7_FILIAL='"+FWxFilial("PC7")+"' AND PC7.PC7_TANQUE='"+cTanque+"'"
      cWherePC7 += " AND PC7.PC7_PRODUT='"+cProdUso+"'"
      If lVerSaldo
         cWherePC7 += " AND PC7.PC7_QUANT > 0"
      EndIf
      cWherePC7 += "%"
   Else
      cWherePC7 := "%PC7.PC7_FILIAL='"+FWxFilial("PC7")+"' AND PC7.PC7_TANQUE='"+cTanque+"'"
      If lVerSaldo
         cWherePC7 += " AND PC7.PC7_QUANT > 0"
      EndIf
      cWherePC7 += "%"
   EndIf

   BEGINSQL Alias cAliasPC7
      SELECT TOP 1 PC7_PRODUT, PC7_QUANT FROM %Table:PC7% PC7 
                     WHERE %Exp:cWherePC7%
                     AND   PC7.%NotDel% ORDER BY PC7_TANQUE, PC7_PRODUT
   ENDSQL

   If !(cAliasPC7)->(Eof())
      AADD( aRet, (cAliasPC7)->PC7_PRODUT )
      AADD( aRet, (cAliasPC7)->PC7_QUANT  )
      AADD( aRet, .T. )
   Else
      AADD( aRet, "" )
      AADD( aRet, 0  )
      AADD( aRet, .F. )
   EndIf
   (cAliasPC7)->(dbCloseArea())

RETURN ( aRet )

/*/{Protheus.doc} F0400107 
Busca o fator de conversão do produto 
@author Michel Sander
@since 26/08/2019
@version 1.0
/*/

User Function F0400107(cProdutUso, nDensUso, nTemTanUso, nIndUso)

   LOCAL    aRet   := {}
   Local    aAreaSB1 := SB1->(GetArea())
   Local    aAreaZZ2 := ZZ2->(GetArea())
   Local    aAreas   := {aAreaSB1, aAreaZZ2, GetArea()}
   Local    cExpr  := ''
   DEFAULT nIndUso := 1

// Busca FATOR DE CONVERSÂO do produto 
   SB1->(dbSetOrder(1))
   SB1->(dbseek(xFilial()+cProdutUso))
   ZZ2->(dbSetOrder(nIndUso))
   cExpr := FWXFilial('ZZ2')+SB1->B1_XTPANP
   If nIndUso == 1
      cExpr += Str(nDensUso, TamSX3('ZZ2_DENSID')[1], TamSX3('ZZ2_DENSID')[2])
      cExpr += Str(nTemTanUso, TamSX3('ZZ2_TEMPER')[1], TamSX3('ZZ2_TEMPER')[2])
   ElseIf nIndUso == 2
      cExpr += Str(nDensUso, TamSX3('ZZ2_DENS20')[1], TamSX3('ZZ2_DENS20')[2])
      cExpr += Str(nTemTanUso, TamSX3('ZZ2_TEMPER')[1], TamSX3('ZZ2_TEMPER')[2])
   EndIf
   If ZZ2->(dbSeek(cExpr))
      AADD(aRet, ZZ2->ZZ2_DENS20)
      AADD(aRet, ZZ2->ZZ2_FATCOR)
      AADD(aRet, .T.)
   Else
      AADD(aRet, 0)
      AADD(aRet, 0)
      AADD(aRet, .F.)
   Endif

   AEval(aAreas, {|x| RestArea(x)})
Return ( aRet )

/*/{Protheus.doc} F0400108
Busca a última medição do tanque
@author Michel Sander
@since 26/08/2019
@version 1.0
/*/

User Function F0400108(cTanque, nFatUso, nDensUso)

   LOCAL aRet      := {}
   LOCAL cAliasPAB := GetNextAlias()
   LOCAL cWherePAB := "%PAB.PAB_FILIAL='"+xFilial("PAB")+"' AND PAB.PAB_TANQUE='"+cTanque+"'%"

   BEGINSQL Alias cAliasPAB
      SELECT TOP 1 PAB_REGUA, PAB_TEMTAN, PAB_TEMAMO, PAB_ALAGUA, PAB_DENSID, PAB_DENS20,
	         PAB_FATOR, PAB_VPROAB, PAB_VPRO20, PAB_MASSA, PAB_VOAGUA, PAB_DATLEI, PAB_HORLEI,
			 PAB_VARV20, PAB_VARVAB, PAB_ESPSEG, PAB_ESPDIS, PAB_VARMAS, PAB_ID
	    FROM %Table:PAB% PAB 
                     WHERE %Exp:cWherePAB%
                     AND   PAB.%NotDel% ORDER BY PAB.PAB_ID DESC
   ENDSQL

   AADD(aRet, (cAliasPAB)->PAB_REGUA)
   AADD(aRet, (cAliasPAB)->PAB_TEMTAN)
   AADD(aRet, (cAliasPAB)->PAB_TEMAMO)
   AADD(aRet, (cAliasPAB)->PAB_ALAGUA)
   AADD(aRet, (cAliasPAB)->PAB_DENSID)
   AADD(aRet, (cAliasPAB)->PAB_DENS20)
   AADD(aRet, (cAliasPAB)->PAB_FATOR)
   AADD(aRet, (cAliasPAB)->PAB_VPROAB)
   AADD(aRet, (cAliasPAB)->PAB_VPRO20)
   AADD(aRet, (cAliasPAB)->PAB_MASSA)
   AADD(aRet, (cAliasPAB)->PAB_VOAGUA)
   AADD(aRet, If(Empty(STOD((cAliasPAB)->PAB_DATLEI)), dDataBase, STOD((cAliasPAB)->PAB_DATLEI)))
   AADD(aRet, If(Empty((cAliasPAB)->PAB_HORLEI)      , Time()   , (cAliasPAB)->PAB_HORLEI))
   AADD(aRet, (cAliasPAB)->PAB_VARV20)
   AADD(aRet, (cAliasPAB)->PAB_VARVAB)
   AADD(aRet, (cAliasPAB)->PAB_ESPSEG)
   AADD(aRet, (cAliasPAB)->PAB_ESPDIS)
   AADD(aRet, (cAliasPAB)->PAB_VARMAS)
   AADD(aRet, (cAliasPAB)->PAB_ID)
   (cAliasPAB)->(dbCloseArea())

Return ( aRet )

/*/{Protheus.doc} F0400109
Atualiza os itens do ciclo de combustível com dados da medição dos tanques
@author Michel Sander
@since 26/08/2019
@version 1.0
/*/

User Function F0400109(oGetDados, nPosLinha, cCicloPAR, lAtualOP)

   LOCAL aSavePAR  := PAR->(GetArea())
   LOCAL _nPosItem := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_ITEM"})
   LOCAL _nPosTank := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_TANQUE"})
   LOCAL _nPosAlt  := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_ALTURA"})
   LOCAL _nPosTem  := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_TEMPER"})
   LOCAL _nPosAmo  := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_TEMAMO"})
   LOCAL _nPosDen  := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_DENSID"})
   LOCAL _nPosD20  := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_DENS20"})
   LOCAL _nPosFat  := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_FATOR"})
   LOCAL _nPosVam  := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_VOLAMB"})
   LOCAL _nPosV20  := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_QUANT"})
   LOCAL _nPosSC2  := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_OP"})


   DEFAULT lAtualOP := .F.

   PAR->(dbSetOrder(2))
   // Atualiza os dados da linha do item posicionado
   If PAR->(dbSeek(xFilial()+cCicloPAR+oGetDados:aCols[nPosLinha,_nPosItem]+oGetDados:aCols[nPosLinha,_nPosTank]))
      Reclock("PAR",.F.)
      PAR->PAR_ALTURA := oGetDados:aCols[nPosLinha,_nPosAlt]
      PAR->PAR_TEMPER := oGetDados:aCols[nPosLinha,_nPosTem]
      PAR->PAR_TEMAMO := oGetDados:aCols[nPosLinha,_nPosAmo]
      PAR->PAR_DENSID := oGetDados:aCols[nPosLinha,_nPosDen]
      PAR->PAR_DENS20 := oGetDados:aCols[nPosLinha,_nPosD20]
      PAR->PAR_FATOR  := oGetDados:aCols[nPosLinha,_nPosFat]
      PAR->PAR_VOLAMB := oGetDados:aCols[nPosLinha,_nPosVam]
      PAR->PAR_QUANT  := oGetDados:aCols[nPosLinha,_nPosV20]
      If lAtualOP
         PAR->PAR_OP  := oGetDados:aCols[nPosLinha,_nPosSC2]
      EndIf
      PAR->(MsUnlock())
   EndIf

   PAR->(RestArea(aSavePAR))

Return

/*/{Protheus.doc} F0400110
// Converte a Capacidade e Espaço de Segurança do tanque a 20ºC 

@project 	DELFT - P04001
@author 	   Michel Sander
@since 		19/07/2019
@version 	P12.1.23
@type 		Function
/*/

User Function F0400110(cTqUso)

   LOCAL nSaldoPC7 := 0
   LOCAL cErro     := ""
   LOCAL aVerPC7   := {}
   LOCAL nCapacid  := 0
   LOCAL aGetPAA   := PAA->(GetArea())

   PAA->(dbSetOrder(1))
   PAA->(dbSeek(xFilial()+cTQUso))

   // Busca o último produto disponível no tanque
   aVerPC7 := U_F0400106(cTqUso,,.F.)
   If !aVerPC7[3]
      cErro := "Saldo inexistente para o tipo de produto no tanque "+cTqUso
      Help(NIL, NIL, "F0400110", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
      PAA->(RestArea(aGetPAA))
      Return ( nCapacid )
   Else
      nSaldoPC7 := aVerPC7[2]
   EndIf

   // Busca o fator de conversão do produto
   aFator := U_F0400107(aVerPC7[1], PAA->PAA_DENSID, PAA->PAA_TEMTAN, 1)
   If !aFator[3]
      cErro := "Fator de Conversão inexistente para a densidade e temperatura cadastrada no tanque "+PAA->PAA_TANQUE+"!"+Chr(13)+Chr(13)
      cErro += "Codigo Produto "+aVerPC7[1]+Chr(13)+Chr(13)
      Help(NIL, NIL, "F0400110", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
      PAA->(RestArea(aGetPAA))
      Return ( nCapacid )
   EndIf

   nCapacid := PAA->PAA_ESPSEG * aFator[2]

   PAA->(RestArea(aGetPAA))

Return ( nCapacid )

/*/{Protheus.doc} F0400111
// Abre ordem de produção a partir do apontamento parcial no ciclo de combustível 

@project 	DELFT - P04001
@author  	Michel Sander
@since 		19/07/2019
@version 	P12.1.23
@type 		Function
/*/

User Function F0400111(cOPUso, cItUso, cSeqUso, cPAR_CODPRO, cPAR_LOCAL, cPAR_QUANT, cSB1_UM, cSB1_SEGUM, dDataUso, dDataFim, cSB1_REVATU, cTpOpUso, dEmisUso, cAutoExp, cPAR_TANQUE)

   LOCAL lGrava   := .T.
   LOCAL aMATA650 := {}
   PRIVATE lMsErroAuto := .F.

   SB1->(dbSeek(xFilial()+cPAR_CODPRO))
   aMATA650  := { {'C2_NUM'		,cOPUso									,NIL},;
      {'C2_ITEM'     ,cItUso									,NIL},;
      {'C2_SEQUEN'   ,cSeqUso									,NIL},;
      {'C2_PRODUTO'  ,cPAR_CODPRO						   ,NIL},;
      {'C2_LOCAL'    ,cPAR_LOCAL   						   ,NIL},;
      {'C2_QUANT'    ,cPAR_QUANT                      ,NIL},;
      {'C2_UM'       ,cSB1_UM						    		,NIL},;
      {'C2_SEGUM'    ,cSB1_SEGUM			       			,NIL},;
      {'C2_DATPRI'   ,dDataUso								,NIL},;
      {'C2_DATPRF'   ,dDataFim		   					,NIL},;
      {'C2_REVISAO'  ,cSB1_REVATU   						,NIL},;
      {'C2_TPOP'     ,cTpOpUso								,NIL},;
      {'C2_EMISSAO'  ,dEmisUso								,NIL},;
      {'C2_XTANQUE'  ,cPAR_TANQUE                     ,NIL},;
      {'AUTEXPLODE'  ,cAutoExp								,NIL} }

   MsExecAuto({|x,Y| Mata650(x,Y)},aMata650,3)
   If lMsErroAuto
      MostraErro()
      lGrava := .F.
   EndIf

Return ( lGrava )

/*/{Protheus.doc} F0400112
// Aponta ordem de produção com dados da medição do ciclo

@project 	DELFT - P04001
@author  	Michel Sander
@since 		19/07/2019
@version 	P12.1.23
@type 		Function  
/*/

User Function F0400112(cTMUso, cPAR_CODPRO, cUM, cPAR_QUANT, cPAR_QTPERD, cPAR_OP, cPAR_TANQUE, dDataUso, cPartTot, cLoteUso, nOpcAuto, cCicloUso, cPAR_LOCAL)

   LOCAL    lGrava     := .T.
   LOCAL    aMATA250   := {}
   LOCAL    nValorApto := cPAR_QUANT

   PRIVATE lMsErroAuto := .F.

   Aadd(aMATA250,{"D3_OP     " , cPAR_OP		, NIL })
   Aadd(aMATA250,{"D3_TM     " , cTmUso      , NIL })
   Aadd(aMATA250,{"D3_QUANT  " , nValorApto  , NIL })
   Aadd(aMATA250,{"D3_LOCAL  " , cPAR_LOCAL  , NIL })
   Aadd(aMATA250,{"D3_PERDA  " , cPAR_QTPERD , NIL })
   Aadd(aMATA250,{"D3_XTANQUE" , cPAR_TANQUE , NIL })
   Aadd(aMATA250,{"D3_PARCTOT" , cPartTot    , NIL })
   Aadd(aMATA250,{"D3_XCICLO"  , cCicloUso   , NIL })

   // Aponta ordem de produção
   MSExecAuto({|x,y| MATA250(x,y)},aMATA250,nOpcAuto)
   If lMsErroAuto
      MostraErro()
      lGrava := .F.
   ENDIF

Return ( lGrava )

/*/{Protheus.doc} F0400113 
Estorno de todos os apontamentos do ciclo

@author Michel Sander
@since 11/07/2019
@version 1.0
@return 
@param  
@type function
/*/

User Function F0400113()

   Local aAreaSD3 := SD3->(GetArea())
   Local aAreaSBC := SBC->(GetArea())
   Local aAreaSC2 := SC2->(GetArea())
   Local aAreaPAR := PAR->(GetArea())
   Local aAreaPC6 := PC6->(GetArea())
   Local aAreaPAB := PAB->(GetArea())
   Local aAreas   := {aAreaSD3, aAreaSBC, aAreaSC2, aAreaPAR, aAreaPC6, aAreaPAB, GetArea()}
   LOCAL cAliasSD3 := GetNextAlias()
   Local cQuery    := ''
   Local cAlPAB    := ''
   LOCAL aMATA650  := {}
   LOCAL lTudoOK   := .T.
   Local aMata250  := {}

   Public nRegSD3 := 0
   PRIVATE lMsErroAuto := .F.

   SD3->(dbSetOrder(2)) //D3_FILIAL+D3_OP+D3_COD+D3_LOCAL
   SBC->(dbOrderNickName("FSW0400102")) //BC_FILIAL+BC_OP+BC_SEQSD3
   SC2->(dbSetOrder(1)) //C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD
   PAR->(dbSetOrder(1)) //PAR_FILIAL+PAR_NCICLO
   PC6->(DbSetOrder(1)) //PC6_FILIAL+PC6_NCICLO+PC6_ITEM+PC6_TANQUE+PC6_OP

   If !U_F0400125() //Verifica se existem outros ciclos em aberto no mesmo tanque antes de estornar este
      AEval(aAreas, {|x| RestArea(x)})
      Return
   EndIf

   // Busca todas as produções do ciclo
   cWhereSD3 := "%SD3.D3_TM = '"+cTmProd+"' And SD3.D3_FILIAL = '"+FWXFilial('SD3')+"' AND D3_XCICLO = '"+PAQ->PAQ_NCICLO+"'%"
   cWherePC6 := "%PC6.PC6_NCICLO = '"+PAQ->PAQ_NCICLO+"'And PC6.PC6_FILIAL = '"+FWXFilial('PC6')+"'%"

   BEGINSQL Alias cAliasSD3
	
		SELECT SD3.R_E_C_N_O_ RECNO,* FROM %Table:SD3% SD3 JOIN %Table:PC6% PC6 
							ON D3_FILIAL = PC6_FILIAL AND D3_OP = PC6_OP
							WHERE SD3.%NotDel% 
							AND PC6.%NotDel% 
							AND SD3.D3_ESTORNO <> 'S' 
							AND SD3.D3_CF ='PR0' 
							AND %Exp:cWhereSD3%
							AND %Exp:cWherePC6% ORDER BY D3_OP
   ENDSQL

   If (cAliasSD3)->(EOF())
      cErro := "Não existe apontamentos de OP para o ciclo."
      Help(NIL, NIL, "F0400113", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
      (cAliasSD3)->(dbCloseArea())
      AEval(aAreas, {|x| RestArea(x)})
      lTudoOk := .F.
      RETURN ( lTudoOk )
   EndIf

   BEGIN TRANSACTION

      While (cAliasSD3)->(!EOF())

         // Estorna o apontamento de perda
         If SBC->(dbSeek(xFilial()+(cAliasSD3)->D3_OP))
            lTudoOk := U_F0400119(SBC->BC_OP, SBC->BC_PRODUTO, SBC->BC_LOCORIG, SBC->BC_QUANT, SBC->BC_XTANQUE, 6)
            If !lTudoOk
               DisarmTransaction()
               lTudoOk := .F.
               Exit
            EndIf
         EndIf

         nRegSD3 := (cAliasSD3)->RECNO
         // Estorna apontamento de produção
         SD3->(dbSetOrder(2)) //D3_FILIAL+D3_DOC+D3_COD
         SD3->(dbGoto((cAliasSD3)->RECNO))

         aMata250 :=  { {"D3_OP" ,   SD3->D3_OP,    NIL},;
            {"D3_QUANT", SD3->D3_QUANT, NIL},;
            {"D3_TM" ,   SD3->D3_TM,    NIL}}

         lMsErroAuto := .F.
         MSExecAuto({|x, y| Mata250(x, y)}, aMata250, 5 )

         If lMsErroAuto
            MostraErro()
            DisarmTransaction()
            lTudoOk := .F.
            Exit
         EndIf

         (cAliasSD3)->(dbSkip())
      End

      // Exclui das Ordens de Produção
      If lTudoOk
         PAR->(dbSetOrder(2))
         PC6->(dbSeek(PAQ->PAQ_FILIAL+PAQ->PAQ_NCICLO))
         While PC6->(!Eof()) .And. PC6->PC6_FILIAL+PC6->PC6_NCICLO == PAQ->PAQ_FILIAL+PAQ->PAQ_NCICLO

            SC2->(dbSeek(xFilial()+PC6->PC6_OP))
            aMATA650  := {}
            aMATA650  := { {'C2_NUM'		,SubStr(PC6->PC6_OP,1,6)	,NIL},;
               {'C2_ITEM'     ,SubStr(PC6->PC6_OP,7,2)	,NIL},;
               {'C2_SEQUEN'   ,SubStr(PC6->PC6_OP,9,3)	,NIL},;
               {'AUTEXPLODE'  ,"S"								,NIL} }
            lMsErroAuto := .F.
            MsExecAuto({|x,Y| Mata650(x,Y)},aMata650,5)
            If lMsErroAuto
               MostraErro()
               DisarmTransaction()
               lTudoOk := .F.
               Exit
            EndIf

            If PAR->(dbSeek(PC6->PC6_FILIAL+PC6->PC6_NCICLO+PC6->PC6_ITEM+PC6->PC6_TANQUE))
               Reclock("PAR",.f.)
               PAR->PAR_OP 	 := ""
               PAR->PAR_QTPROD := 0
               PAR->PAR_QTTOTA := 0
               PAR->PAR_PEPERD := 0
               PAR->PAR_QTPERD := 0
               PAR->PAR_STATUS := ''
               PAR->(MsUnlock())
            EndIf
            PC6->(dbSkip())

         End
      EndIf

      // Estorna rateio de perda para apontamentos de produção
      If lTudoOk
         If PC6->(dbSeek(PAQ->PAQ_FILIAL+PAQ->PAQ_NCICLO))
            Do While PC6->(!Eof()) .And. PC6->PC6_FILIAL+PC6->PC6_NCICLO == ;
                  PAQ->PAQ_FILIAL+PAQ->PAQ_NCICLO
               Reclock("PC6",.F.)
               PC6->(dbDelete())
               PC6->(MsUnlock())
               PC6->(dbSkip())
            EndDo
         EndIf
      EndIf

      // Retorna o status para andamento
      If lTudoOk
         Reclock("PAQ",.F.)
         PAQ->PAQ_CONSU  := 0
         PAQ->PAQ_PERDA  := 0
         PAQ->PAQ_STATUS := "1"
         PAQ->(MsUnlock())
      EndIf

      //Estorna medições
      If lTudoOk
         cQuery := " Select PAB.R_E_C_N_O_ RecnoPAB From "+RetSqlName('PAB')+" PAB "
         cQuery += " Join "+RetSqlName('PB5')+" PB5 On "
         cQuery += ' PB5_CODIGO = PAB_TIPOPE '
         cQuery += " Where PAB_FILIAL = '"+FWXFilial('PAB')+"' "
         cQuery += " And   PAB_NCICLO = '"+PAQ->PAQ_NCICLO+"' "
         cQuery += " And   PAB.D_E_L_E_T_ = '' "
         cQuery += " And   PB5_FILIAL = '"+FWXFilial('PB5')+"' "
         cQuery += " And   PB5_LTUNIC <> '1' "
         cQuery += " And   PB5_MOVEST <> '1' "
         cQuery += " And   PB5_TQDEST <> '1' "
         cQuery += " And   PB5_INSPEC <> '1' "
         cQuery += " And   PB5_RATEIO <> '1' "
         cQuery += " And   PB5.D_E_L_E_T_ = '' "
         cQuery := ChangeQuery(cQuery)

         cAlPAB := MPSysOpenQuery(cQuery)
         While !(cAlPAB)->(EoF())
            PAB->(DbGoTo((cAlPAB)->RecnoPAB))
            If RecLock('PAB', .F.)
               PAB->(DbDelete())
               PAB->(MsUnlock())
            EndIf
            (cAlPAB)->(DbSkip())
         EndDo

         (cAlPAB)->(DbCloseArea())
      EndIf

   END TRANSACTION

   AEval(aAreas, {|x| RestArea(x)})
   (cAliasSD3)->(dbCloseArea())

Return ( lTudoOk )

/*/{Protheus.doc} F0400114
// Busca os volumes nas reguas CM e MM

@project 	DELFT - P04001
@author  	Michel Sander
@since 		19/07/2019
@version 	P12.1.23
@type 		Function
/*/

User Function F0400114(cTanRegua, nUsoCM, nUsoMM)

   LOCAL aRet := {}
   LOCAL lReguaZero := .F.

   // Busca Volume na Regua CM
   PAC->(dbSetOrder(1))//PAC_FILIAL+PAC_TANQUE+PAC_REGUA
   If !PAC->(dbSeek(xFilial()+AvKey(cTanRegua, 'PAC_TANQUE')+AvKey(nUsoCM, 'PAC_REGUA')))
      AADD(aRet, 0)
      AADD(aRet, lReguaZero)
      Return ( aRet )
   ENDIF

   // Verifica se existe regua CM igual a 0
   If Alltrim(nUsoCM) == "0"
      lReguaZero := .T.
   Endif
   AADD(aRet, PAC->PAC_VOLUME)
   AADD(aRet, lReguaZero)
   lReguaZero := .F.

   // Busca Volume na Regua MM
   PAD->(dbSetOrder(1))//PAD_FILIAL+PAD_TANQUE+PAD_REGUA
   If !PAD->(dbSeek(xFilial()+AvKey(cTanRegua, 'PAD_TANQUE')+AvKey(nUsoMM, 'PAC_REGUA')))
      AADD(aRet, 0)
      AADD(aRet, lReguaZero)
      Return ( aRet )
   ENDIF

   // Verifica se existe regua MM igual a 0
   If Alltrim(nUsoMM) == "0"
      lReguaZero := .T.
   Endif

   AADD(aRet, PAD->PAD_VOLUME)
   AADD(aRet, lReguaZero)

Return ( aRet )

/*/{Protheus.doc} F0400115
Ajusta o local de empenho na abertura de OP pelo ciclo de produção

@author Michel Sander 
@since 11/07/2019
@version 1.0
@return 
@param  
@type function
/*/

User Function F0400115(cOpEmp, cProdEmp, cTanEmp, cLocEmp, cLotEmp, nQtdEmp)

   LOCAL lRetEmp := .T.

   DEFAULT nQtdEmp := 0
   Default cLotEmp := Posicione('PAA', 1, FWXFilial('PAA')+cTanEmp, 'PAA_PRXLOT')

   SD4->(dbSetOrder(2))
   If SD4->(dbSeek(xFilial()+Padr(cOpEmp,14)))
      Do While SD4->(!Eof()) .And. SD4->D4_FILIAL+SD4->D4_OP == xFilial("SD4")+Padr(cOpEmp,14)

         If RecLock('SD4', .F.)
            SD4->D4_XTANQUE := cTanEmp
            SD4->D4_XLOTE   := cLotEmp
            SD4->(MsUnlock())
         EndIf
         SD4->(dbSkip())
      EndDo
   EndIf

Return ( lRetEmp )

/*/{Protheus.doc} F0400116
Busca a última OP apontada para o tanque 
@author Michel Sander
@since 26/08/2019
@version 1.0
/*/

User Function F0400116(cPro, cLoc)

   LOCAL cOpBusca := ""
   LOCAL cAliasC2 := GetNextAlias()
   LOCAL cWhereC2 := "%C2_FILIAL = '"+FWxFilial("SC2")+"' AND C2_DATPRF <> '' AND C2_PRODUTO='"+cPro+"' AND C2_XTANQUE='"+cLoc+"'%"

   BEGINSQL Alias cAliasC2
		SELECT MAX(C2_NUM+C2_ITEM+C2_SEQUEN) C2_NUM FROM %Table:SC2% SC2
				 WHERE %Exp:cWhereC2% AND SC2.%NotDel%
   ENDSQL

   cOpBusca := (cAliasC2)->C2_NUM
   (cAliasC2)->(dbCloseArea())

REturn ( cOpBusca )

/*/{Protheus.doc} F0400119 
Apontamento de perdas
@author Michel Sander
@since 26/08/2019
@version 1.0
/*/

User Function F0400119(cOpPerda, cProPerda, cLocPerda, nQtPerda, cTanPerd, nOpcPerda)

   Local aCabec := {}
   Local aItens := {}
   Local aLinha := {}
   LOCAL lPerdaOK  := .T.
   LOCAL aAreaSD4  := SD4->(GetArea())
   LOCAL aAreaSB1  := SB1->(GetArea())
   LOCAL aAreaSD3  := SD3->(GetArea())
   LOCAL aSaldoReq := {}
   LOCAL cErro     := ""

   SD4->(dbSetOrder(2))
   If SD4->(dbSeek( xFilial()+cOpPerda ))

      // Monta dados da perda
      aCabec := { {"BC_OP", cOpPerda, NIL} }
      Do While SD4->(!Eof()) .And. SD4->D4_FILIAL+AllTrim(SD4->D4_OP) == xFilial("SD4")+AllTrim(cOpPerda)

         // Só considera matéria-prima
         cTipoUso := Posicione("SB1",1,xFilial("SB1")+SD4->D4_COD,"B1_TIPO")
         If !cTipoUso $ "MP/PI"
            SD4->(dbSkip())
            Loop
         EndIf

         // Verifica se a perda calculada poderá ser requisitada do tanque
         aSaldoReq := U_F0400106(cTanPerd, SD4->D4_COD, .F.)
         If nOpcPerda != 6
            If (aSaldoReq[2] - nQtPerda) < 0
               cErro := "O valor da perda calculada é superior ao saldo de materia-prima"+CRLF+CRLF
               cErro += "Produto "+SD4->D4_COD+CRLF
               cErro += "Tanque  "+cTanPerd+CRLF
               cErro += "Valor de Perda  = "+TransForm(nQtPerda,PesqPict("SD3","D3_QUANT"))+CRLF
               cErro += "Saldo no Tanque = "+TransForm(aSaldoReq[2],PesqPict("PC7","PC7_QUANT"))
               Help(NIL, NIL, "F0400119", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o saldo antes de finalizar o ciclo e repita a operação."})
               lPerdaOk := .F.
               Exit
            EndIf
         EndIf

         aItens   := {  {"BC_PRODUTO",SD4->D4_COD     ,NIL},;
            {"BC_LOCORIG",SD4->D4_LOCAL   ,NIL},;
            {"BC_TIPO",   "R"             ,NIL},;
            {"BC_MOTIVO","FH"             ,NIL},;
            {"BC_QUANT",  nQtPerda        ,NIL},;
            {"BC_QTDDEST",nQtPerda        ,NIL},;
            {"BC_DATA",   dDataBase       ,NIL},;
            {"BC_XTANQUE",cTanPerd        ,NIL} }
         AAdd(aLinha ,aItens)
         SD4->(dbSkip())
      EndDo

      //Grava as perdas
      // nOpcPerda = 3 (Inclusão) / 4 (Alteração) / 6 (Exclusão)
      If lPerdaOk
         lMSErroAuto := .F.
         Pergunte("MTA650",.F.)
         mv_par01 := 1
         MsExecAuto ({|x,y,z|MATA685(x,y,z) },aCabec,aLinha,nOpcPerda)
         If lMSErroAuto
            MostraErro()
            lPerdaOk := .F.
         Endif
      EndIf

   EndIf

   SD4->(RestArea(aAreaSD4))
   SB1->(RestArea(aAreaSB1))
   SD3->(RestArea(aAreaSD3))

Return ( lPerdaOk )

/*/{Protheus.doc} F0400120
Verifica se existe mais de um produto com saldo por lote no mesmo tanque 
@author Michel Sander
@since 26/08/2019
@version 1.0
/*/

User Function F0400120(cVerTQ)

   LOCAL nDifTQ    := 0
   LOCAL cAliasTC7 := GetNextAlias()
   LOCAL cLocDIF   := "%PC7_FILIAL = '"+FWXFilial("PC7")+"' AND PC7_TANQUE='"+cVerTQ+"' AND PC7_QUANT > 0%"
   LOCAL aAreaTQ   := GetArea()

   BEGINSQL Alias cAliasTC7
      SELECT PC7_TANQUE, COUNT(*) PC7_DIF FROM %Table:PC7% PC7 
                                WHERE PC7.%NotDel% 
                                AND %Exp:cLocDIF%
                                GROUP BY PC7_TANQUE HAVING COUNT(*) > 1
   ENDSQL

   If (cAliasTC7)->(!EOf())
      nDifTQ := (cAliasTC7)->PC7_DIF
   EndIf
   (cAliasTC7)->(dbCloseArea())
   RestArea(aAreaTQ)

Return ( nDifTQ )

/*/{Protheus.doc} F0400121
Rotina para selecionar o tanque de alimentação de matéria prima no ciclo de produção
@author Michel Sander
@since 21/02/2020
@version 1.0
/*/

User Function F0400121()

   LOCAL nL := 2
   LOCAL nC := 5
   LOCAL nClick   := 0
   LOCAL aComboTQ := {}
   LOCAL aComboOP := {}
   LOCAL cComboTQ := ""
   LOCAL cComboOP := ""
   LOCAL aAreaPAA := PAA->(GetArea())
   LOCAL aAreaPB5 := PB5->(GetArea())
   LOCAL aRetAlim := {}

   //Preenche o combobox dos tanques
   PAA->(dbSetOrder(1))
   PAA->(dbGotop())
   AADD(aComboTQ,"")
   PAA->(dbEval({|| AADD(aComboTQ,PAA->PAA_TANQUE+" | "+PAA->PAA_DESCR)}))

   //Preenche o combobox dos tipos de operação
   PB5->(dbSetOrder(1))
   PB5->(dbGotop())
   AADD(aComboOP,"")
   PB5->(dbEval({|| IF(PB5->PB5_TQDEST=='1',AADD(aComboOP,PB5->PB5_CODIGO+" | "+PB5->PB5_DESCR),)}))

   // Monta a janela de medições
   DEFINE MSDIALOG oDlgAli TITLE OemToAnsi("Alimentação de tanques") FROM 0,0 TO 130,975 PIXEL of oMainWnd PIXEL
   @ nL, nC  TO nL+35, nC+480 LABEL " Transferência de Matéria-Prima " PIXEL OF oDlgAli
   nL += 9

   // Apresenta os combos
   @ nL, nC+05 SAY oCampo01 Var 'Escolha o Tanque'       SIZE 100,10 PIXEL
   oCampo01:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nL, nC+170 SAY oCampo02 Var 'Tipo de Operação'      SIZE 100,10 PIXEL
   oCampo02:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   nL += 7
   @ nL,   nC+05  ComboBox oCmbTan Var cComboTQ Items aComboTQ OF oDlgAli SIZE 150,15 PIXEL
   oCmbTan:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   @ nL,   nC+170 ComboBox oCmbOpe Var cComboOP Items aComboOP OF oDlgAli SIZE 150,15 PIXEL
   oCmbOpe:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)

   // botões de controle
   @ nL-4, nC+350 BUTTON oConf   PROMPT "Confirmar" ACTION Processa( { || nClick := 1, oDlgAli:End() } ) SIZE 050,15 PIXEL OF oDlgAli
   @ nL-4, nC+420 BUTTON oCanc   PROMPT "Cancelar"  ACTION Processa( { || nClick := 0, oDlgAli:End() } ) SIZE 050,15 PIXEL OF oDlgAli
   nL += 25
   @ nL, nC  TO nL+1, nC+480 PIXEL OF oDlgAli

   ACTIVATE MSDIALOG oDlgAli CENTER

   If nClick == 1
      AADD( aRetAlim, SubStr(cComboTQ,1,6) )
      AADD( aRetAlim, SubStr(cComboOP,1,2) )
      AADD( aRetAlim, .T. )
   else
      AADD( aRetAlim, "" )
      AADD( aRetAlim, "" )
      AADD( aRetAlim, .F. )
   EndIf

   PAA->(RestArea(aAreaPAA))
   PB5->(RestArea(aAreaPB5))

Return ( aRetAlim )

/*/{Protheus.doc} F0400121
Rotina para selecionar o produto que será medido em caso de inicio de operações no tanque
@author Michel Sander
@since 10/06/2020
@version 1.0
/*/

User Function F0400122()

   LOCAL nL := 2
   LOCAL nC := 5
   LOCAL cEscProd := Space(TamSX3('B1_COD')[1])
   Local cProduto := ''

   PRIVATE oEscDesc
   PRIVATE cEscDesc := ""
   Private nClick   := 0

   // Monta a janela de produtos
   DEFINE MSDIALOG oDlgAli TITLE OemToAnsi("Inicio de Operação- DEFINIÇÃO DE PRODUTO NO TANQUE") FROM 0,0 TO 78,718 PIXEL of oMainWnd PIXEL
   @ nL, nC  TO nL+35, nC+355 LABEL " Aponte o produto no tanque " PIXEL OF oDlgAli
   nL += 9

   // Apresenta os combos
   @ nL, nC+05 SAY oCampo01 Var 'Escolha o Produto'       SIZE 100,10 PIXEL
   oCampo01:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   nL += 7
   @ nL,   nC+05  MSGET oEscProd VAR cEscProd F3 "SB1" Valid VerPrd(cEscProd) PIXEL OF oDlgAli SIZE 70,15 PIXEL
   oEscProd:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)
   //nL += 10
   @ nL,   nC+85  MSGET oEscDesc VAR cEscDesc When .F. PIXEL OF oDlgAli SIZE 150,15 PIXEL
   oEscDesc:oFont := TFont():New('Arial',,15,,.T.,,,,.T.,.F.)

   // botões de controle
   @ nL, nC+240 BUTTON oConf   PROMPT "Confirmar" ACTION Processa( { || cProduto := cEscProd, oDlgAli:End() } ) SIZE 050,15 PIXEL OF oDlgAli
   @ nL, nC+300 BUTTON oCanc   PROMPT "Cancelar"  ACTION Processa( { || oDlgAli:End() } ) SIZE 050,15 PIXEL OF oDlgAli
   //nL += 25
   //@ nL, nC  TO nL+1, nC+480 PIXEL OF oDlgAli

   ACTIVATE MSDIALOG oDlgAli CENTER

Return cProduto

/*/{Protheus.doc} F0400122
Rotina para validar o código de produto
@author Michel Sander
@since 10/06/2020
@version 1.0
/*/

Static Function VerPrd(cVerPrd)

   LOCAL cSavePRO := SB1->(GetArea())
   LOCAL lRetPRO  := .T.

   If Empty(cVerPrd)
      Return .T.
   EndIf

   If !SB1->(dbSeek(FWxFilial()+cVerPrd))
      Help(NIL, NIL, "F0400102- VerPrd()", NIL, "Produto Inválido", 1, 0, NIL, NIL, NIL, NIL, NIL, {'Digite um código de produto existente.'})
      lRetPro := .F.
   EndIf
   If lRetPRO .And. !SB1->B1_XTPANP $ '12'
      Help(NIL, NIL, "F0400102- VerPrd()", NIL, "O Produto selecionado não pode estar em um tanque.", 1, 0, NIL, NIL, NIL, NIL, NIL, {'Verifique o campo B1_XTPANP.'})
      lRetPro := .F.
   EndIf

   cEscDesc := SB1->B1_DESC
   oEscDesc:Refresh()
   SB1->(RestArea(cSavePro))

Return ( lRetPro )

User Function F04001A7(cProdutUso, nTempTan, nTempAm, nDensUso)

   LOCAL    aRet   := {}
   Local    aAreaLDH := LDH->(GetArea())
   Local    aAreas   := {aAreaLDH, GetArea()}
   Local    cExpr  := ''

   // Busca FATOR DE CONVERSÂO do produto
   LDH->(dbSetOrder(1)) //LDH_FILIAL+LDH_COD+STR(LDH_TEMPTQ,5,2)+STR(LDH_TEMPAM,5,2)+STR(LDH_DENSID,6,4)
   cExpr := FWXFilial('LDH')+AvKey(cProdutUso, 'LDH_COD')
   cExpr += Str(nTempTan,TamSX3('LDH_TEMPTQ')[1], TamSX3('LDH_TEMPTQ')[2])
   cExpr += Str(nTempAm, TamSX3('LDH_TEMPAM')[1], TamSX3('LDH_TEMPAM')[2])
   cExpr += Str(nDensUso,TamSX3('LDH_DENSID')[1], TamSX3('LDH_DENSID')[2])

   If LDH->(dbSeek(cExpr))
      AADD(aRet, LDH->LDH_DENS20)
      AADD(aRet, LDH->LDH_FATCOR)
      AADD(aRet, .T.)
   Else
      AADD(aRet, 0)
      AADD(aRet, 0)
      AADD(aRet, .F.)
   Endif

   AEval(aAreas, {|x| RestArea(x)})
Return ( aRet )

/*/{Protheus.doc} F0400124
   Gera o saldo inicial de um produto em um local zerado
   @type  Function
   @author Gianluca Moreira
   @since 25/06/2020
   @version version
   @param cProduto, character, Produto
   @param cLocal, character, Local
   @return lMsErroAuto, logical, Se houve erro
   /*/
User Function F0400124(cProduto, cLocal)
   Local aVetor := {}

   Private lMsErroAuto := .F.
   aVetor :={;
      {"B9_FILIAL", FWxFilial('SB9'), Nil},;
      {"B9_COD",    cProduto,         Nil},;
      {"B9_LOCAL",  cLocal,           Nil},;
      {"B9_DATA",   GetMV('MV_ULMES'),Nil},;
      {"B9_QINI",   0,                Nil} }

//Iniciando transação e executando saldos iniciais
   Begin Transaction
      MSExecAuto({|x, y| Mata220(x, y)}, aVetor, 3)

      //Se houve erro, mostra mensagem
      If lMsErroAuto
         MostraErro()
         DisarmTransaction()
      EndIf
   End Transaction

Return lMsErroAuto

/*/{Protheus.doc} F0400126
   Verifica os recebimentos antes de liberar leitura com tanque em status de recebimento
   @type  Function
   @author Michel Sander
   @since 25/06/2020
   @version version
   @param cProduto, character, Produto
   @param cLocal, character, Local
   @return lMsErroAuto, logical, Se houve erro
   /*/

User Function F0400126(cProdUso, cTqUso)

   LOCAL lReceb     := .T.
   LOCAL cAliasSD1  := GetNextAlias()
   Local cWhereSD1  := ""
   LOCAL cPtoUso    := ""
   LOCAL cAnp       := ""

   PAG->(dbSetOrder(4))
   GWV->(dbSetOrder(8))
   GX4->(dbSetOrder(1))
   GVF->(dbSetOrder(1))
   SB1->(dbSetOrder(1))
   SD1->(dbSetOrder(1))

   // Filtro das Notas
   cWhereSD1 := "%F1_FILIAL='"+FwxFilial("SF1")+"' AND F1_STATUS = '' AND F1_TPFRETE NOT IN ('','S')%"

   // Seleciona as pré-notas de entrada não classificadas
   BEGINSQL Alias cAliasSD1

	SELECT SF1.F1_FILIAL, SF1.F1_STATUS, SF1.F1_TPFRETE, SD1.D1_FILIAL, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_FORNECE, SD1.D1_LOJA, 
		   SD1.D1_COD, SD1.D1_ITEM, SD1.D1_LOCAL, SD1.D1_XTANQUE, SD1.D1_PEDIDO, SD1.D1_ITEMPC
		   FROM %Table:SF1% SF1 JOIN %Table:SD1% SD1 ON F1_FILIAL=D1_FILIAL AND F1_DOC=D1_DOC AND F1_SERIE=D1_SERIE AND F1_FORNECE=D1_FORNECE AND F1_LOJA=D1_LOJA
         WHERE SF1.%NotDel% AND SD1.%NotDel% And %Exp:cWhereSD1%
		   ORDER BY D1_DOC
   ENDSQL

   While !(cAliasSD1)->(Eof())

      // Verifica se o documento pertence ao tanque medido
      If (cAliasSD1)->D1_XTANQUE <> cTqUso
         (cAliasSD1)->(dbSkip())
         Loop
      EndIf

      // Verifica se o item é combustível
      cAnp := AllTrim(Posicione("SB1",1,FwxFilial("SB1")+(cAliasSD1)->D1_COD,"B1_XTPANP"))
      If Empty(cAnp) .Or. cAnp == '3'
         (cAliasSD1)->(dbSkip())
         Loop
      EndIf

      // Realiza busca na gestão de frete embarcador
      If !Empty((cAliasSD1)->D1_PEDIDO) .And. !Empty((cAliasSD1)->D1_ITEMPC)
         If PAG->(dbSeek((cAliasSD1)->D1_FILIAL+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_ITEM))
            If GWV->(dbSeek(PAG->PAG_FILIAL+PAG->PAG_NUMOCD))
               If GX4->(dbSeek(GWV->GWV_FILIAL+GWV->GWV_NRMOV))
                  cPtoUso := GX4->GX4_FILIAL+GX4->GX4_NRMOV
                  While GX4->(!Eof()) .And. GX4->GX4_FILIAL+GX4->GX4_NRMOV == cPtoUso
                     If GVF->(dbSeek(xFilial()+GX4->GX4_CDPTCT))
                        If GVF->GVF_XIFDTC <> '1'
                           GX4->(dbSkip())
                           Loop
                        EndIf
                        If GX4->GX4_XTANQU == cTqUso
                           lReceb := .F.
                           Exit
                        EndIf
                     EndIf
                     GX4->(dbSkip())
                  EndDo
               EndIf
            EndIf
         EndIf
      EndIf
      (cAliasSD1)->(DbSkip())

   Enddo

   (cAliasSD1)->(dbCloseArea())

Return ( lReceb )
