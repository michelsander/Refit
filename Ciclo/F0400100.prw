#Include 'Totvs.ch'
#Include 'FwMvcDef.ch'
#DEFINE MOD_DADOS 1
#DEFINE MOD_INTER 2

/*/{Protheus.doc} F0400100    
//Funcao para cadastro e apontamento de ciclos de producao          
@project 	DELFT - P04001 
@author 	Michel Sander 
@since 		28/06/2019
@version 	P12.1.23
@type 		Function    
/*/

User Function F0400100()

	PRIVATE oBrowse
	PRIVATE cAliasTMP := "TPAA"
	PRIVATE oGetDados
	PRIVATE aCampos := {}, aSeek := {}, aDados := {}, aValores := {}, aFieFilter := {}, cArqTrb, cIndice1, cArq
	PRIVATE cTmProd  := GetMv("FS_C040011")
	PRIVATE l250Auto := .T.
	PRIVATE cCusmed  := ""

	dbSelectArea("PAQ")
	dbSetOrder(2)
	dbSelectArea("PAR")
	dbSetOrder(1)
	dbSelectArea("PC6")
	dbSetOrder(1)

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('PAQ')
	oBrowse:SetDescription('Ciclo de Produção de Combustível')
	oBrowse:AddLegend( "PAQ->PAQ_STATUS  = '1'", "GREEN" 	, "Em Aberto"				 )
	oBrowse:AddLegend( "PAQ->PAQ_STATUS  = '2'", "YELLOW" , "Em Andamento"			 )
	oBrowse:AddLegend( "PAQ->PAQ_STATUS  = '3'", "RED"		, "Concluído"    			 )
	oBrowse:Activate()

Return

Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Pesquisar'  ACTION 'PesqBrw'	 		OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.F0400100' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.F0400100' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Produzir'   ACTION 'U_F0400101' 		OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.F0400100' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.F0400100' OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Estornar'   ACTION 'U_F0400104'       OPERATION 6 ACCESS 0

Return aRotina

Static Function ModelDef()

	Local oModel
	Local oStruPAQ := FWFormStruct(1,"PAQ")
	Local oStruPAR := FWFormStruct(1,"PAR")
	Local oStruPC6 := FWFormStruct(1,"PC6")

	Local bCommit   := {|oMdl| FWFormCommit(oMdl,,,,{|oMdl| PAQCommit(oMdl)})}
	Local bPARLinOk := {|oMdl| PARLinOk(oMdl)}

	Local aTPAQPro  := CreateTrigger("PAQ_CODPRO", '01')
	Local aTPAQPro2 := CreateTrigger("PAQ_CODPRO", '02')
	Local aTPARPro  := CreateTrigger("PAR_CODPRO", '01')
	Local aTPARPro2 := CreateTrigger("PAR_CODPRO", '02')
	Local aTLocPro := CreateTrigger("PAQ_TANQUE")

	//Adiciona campo da legenda de usuário
	oStruPAR:AddField( ;
		'  ' , ; 		// [01] C Titulo do campo
	'  ' , ; 		// [02] C ToolTip do campo
	'PAR_LEGEND' , ;    // [03] C identificador (ID) do Field
	'C' , ;             // [04] C Tipo do campo
	50 , ;              // [05] N Tamanho do campo
	0 , ;               // [06] N Decimal do campo
	NIL , ;             // [07] B Code-block de validação do campo
	NIL , ;             // [08] B Code-block de validação When do campo
	NIL , ;             // [09] A Lista de valores permitido do campo
	NIL , ;             // [10] L Indica se o campo tem preenchimento obrigatório
	{ || LegPar(1) } , ; // [11] B Code-block de inicializacao do campo
	NIL , ;             // [12] L Indica se trata de um campo chave
	.F. , ;             // [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )               // [14] L Indica se o campo é virtual

	oStruPAR:AddField( ;
		'Status' , ; 		// [01] C Titulo do campo
	'Status' , ; 		// [02] C ToolTip do campo
	'PAR_DESLEG' , ;    // [03] C identificador (ID) do Field
	'C' , ;             // [04] C Tipo do campo
	15 , ;              // [05] N Tamanho do campo
	0 , ;               // [06] N Decimal do campo
	NIL , ;             // [07] B Code-block de validação do campo
	NIL , ;             // [08] B Code-block de validação When do campo
	NIL , ;             // [09] A Lista de valores permitido do campo
	NIL , ;             // [10] L Indica se o campo tem preenchimento obrigatório
	{ || LegPar(2) } , ; // [11] B Code-block de inicializacao do campo
	NIL , ;             // [12] L Indica se trata de um campo chave
	.F. , ;             // [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )               // [14] L Indica se o campo é virtual

	oStruPAQ:AddTrigger( ;
		aTPAQPro[1] , ;       // [01] Id do campo de origem
	aTPAQPro[2] , ;       // [02] Id do campo de destino
	aTPAQPro[3] , ;       // [03] Bloco de codigo de validao da execuo do gatilho
	aTPAQPro[4] )       // [04] Bloco de codigo de execuo do gatilho

	oStruPAQ:AddTrigger( ;
		aTPAQPro2[1] , ;       // [01] Id do campo de origem
	aTPAQPro2[2] , ;       // [02] Id do campo de destino
	aTPAQPro2[3] , ;       // [03] Bloco de codigo de validao da execuo do gatilho
	aTPAQPro2[4] )       // [04] Bloco de codigo de execuo do gatilho

	oStruPAR:AddTrigger( ;
		aTPARPro[1] , ;       // [01] Id do campo de origem
	aTPARPro[2] , ;       // [02] Id do campo de destino
	aTPARPro[3] , ;       // [03] Bloco de codigo de validao da execuo do gatilho
	aTPARPro[4] )       // [04] Bloco de codigo de execuo do gatilho

	oStruPAR:AddTrigger( ;
		aTPARPro2[1] , ;       // [01] Id do campo de origem
	aTPARPro2[2] , ;       // [02] Id do campo de destino
	aTPARPro2[3] , ;       // [03] Bloco de codigo de validao da execuo do gatilho
	aTPARPro2[4] )       // [04] Bloco de codigo de execuo do gatilho

	oStruPAQ:AddTrigger( ;
		aTLocPro[1] , ;       // [01] Id do campo de origem
	aTLocPro[2] , ;       // [02] Id do campo de destino
	aTLocPro[3] , ;       // [03] Bloco de codigo de validao da execuo do gatilho
	aTLocPro[4] )       // [04] Bloco de codigo de execuo do gatilho

	oModel := MPFormModel():New("M0400101",,{|oMdl| VldPos(oMdl, .T.)},bCommit, /*bCancel*/ )
	oModel:SetDescription("Ciclo de Produçãoo de Combustível")
	oModel:addFields('PAQMASTER',,oStruPAQ)
	oModel:addGrid('PARDETAIL','PAQMASTER',oStruPAR,,bPARLinOk)
	oModel:addGrid('PC6DETAIL','PARDETAIL',oStruPC6)
	oModel:GetModel( 'PARDETAIL' ):SetUniqueLine( {'PAR_TANQUE' } )
	oModel:SetRelation("PARDETAIL", { {"PAR_FILIAL",'FwxFilial("PAR")'}, {"PAR_NCICLO","PAQ_NCICLO"  } }, PAR->(IndexKey(1)))
	oModel:GetModel( 'PC6DETAIL' ):SetUniqueLine( { 'PC6_OP' } )
	oModel:SetRelation("PC6DETAIL", { {"PC6_FILIAL",'FwxFilial("PC6")'}, {"PC6_NCICLO","PAR_NCICLO"}, {"PC6_TANQUE","PAR_TANQUE"} }, PC6->(IndexKey(1)))
	oModel:SetPrimaryKey({'PAQ_FILIAL', 'PAQ_STATUS', 'PAQ_NCICLO' })

	oModel:GetModel( "PARDETAIL" ):SetOptional(.T.)
	oModel:GetModel( "PC6DETAIL" ):SetOnlyView()
	oModel:GetModel( "PC6DETAIL" ):SetOptional(.T.)
	oModel:GetModel( "PAQMASTER" ):SetDescription( "Ciclo de Produção de Combustível" )
	oModel:GetModel( "PARDETAIL" ):SetDescription( "Itens do Ciclo"  )
	oModel:GetModel( "PC6DETAIL" ):SetDescription( "Apontamentos de Produção"  )
	oModel:SetVldActivate({|oModel| VldActiv(oModel)})

	oStruPAQ:SetProperty("PAQ_DESCR",MODEL_FIELD_INIT, { || If(!INCLUI,Posicione("SB1",1,xFIlial("SB1")+PAQ->PAQ_CODPRO,"B1_DESC"),"")})
	//oStruPAQ:SetProperty('PAQ_TANQUE', MODEL_FIELD_VALID, {|| U_F0400125()})
	oStruPAQ:SetProperty('PAQ_TANQUE', MODEL_FIELD_OBRIGAT, .T.)
	oStruPAQ:SetProperty('PAQ_LOCAL',  MODEL_FIELD_OBRIGAT, .T.)
	oStruPAQ:SetProperty('PAQ_CODPRO', MODEL_FIELD_OBRIGAT, .T.)
	oStruPAQ:SetProperty('PAQ_DATA',   MODEL_FIELD_OBRIGAT, .T.)

Return oModel

Static Function ViewDef()

	Local oModel := ModelDef()
	Local oView  := FWFormView():New()
	Local oStrPAQ:= FWFormStruct(2, 'PAQ')
	Local oStrPAR:= FWFormStruct(2, 'PAR')
	Local oStrPC6:= FWFormStruct(2, 'PC6')
	Local nOperMnu := oModel:GetOperation()

	oView:SetModel(oModel)
	oView:AddField('CABEC' 	  , oStrPAQ, 'PAQMASTER' )
	oView:AddGrid('ITENS_PAR' , oStrPAR, 'PARDETAIL')
	oView:AddGrid('ITENS_PC6' , oStrPC6, 'PC6DETAIL')

	oStrPAQ:RemoveField("PAQ_STATUS")
	//oStrPAQ:RemoveField("PAQ_CONSU")
	//oStrPAQ:RemoveField("PAQ_PERDA")
	oStrPAQ:SetProperty('PAQ_CONSU', MVC_VIEW_CANCHANGE, .F.)
	oStrPAQ:SetProperty('PAQ_PERDA', MVC_VIEW_CANCHANGE, .F.)

	oStrPAR:AddField( ;	// Ord. Tipo Desc.
	'PAR_LEGEND'    , ;   	// [01]  C   Nome do Campo
	"00"            , ;     // [02]  C   Ordem
	'  '         , ;     // [03]  C   Titulo do campo
	'  '         , ;     // [04]  C   Descricao do campo
	{ '  ' }     , ;     // [05]  A   Array com Help
	'C'             , ;     // [06]  C   Tipo do campo
	'@BMP'          , ;     // [07]  C   Picture
	NIL             , ;     // [08]  B   Bloco de Picture Var
	''              , ;     // [09]  C   Consulta F3
	.F.             , ;     // [10]  L   Indica se o campo é alteravel
	NIL             , ;     // [11]  C   Pasta do campo
	NIL             , ;     // [12]  C   Agrupamento do campo
	NIL				, ;     // [13]  A   Lista de valores permitido do campo (Combo)
	NIL             , ;     // [14]  N   Tamanho maximo da maior opção do combo
	NIL             , ;     // [15]  C   Inicializador de Browse
	.T.             , ;     // [16]  L   Indica se o campo é virtual
	NIL             , ;     // [17]  C   Picture Variavel
	NIL             )       // [18]  L   Indica pulo de linha após o campo

	oStrPAR:AddField( ;	// Ord. Tipo Desc.
	'PAR_DESLEG'    , ;   	// [01]  C   Nome do Campo
	"01"            , ;     // [02]  C   Ordem
	'Status'         , ;     // [03]  C   Titulo do campo
	'Status'         , ;     // [04]  C   Descricao do campo
	{ 'Status' }     , ;     // [05]  A   Array com Help
	'C'             , ;     // [06]  C   Tipo do campo
	NIL 	          , ;     // [07]  C   Picture
	NIL             , ;     // [08]  B   Bloco de Picture Var
	''              , ;     // [09]  C   Consulta F3
	.F.             , ;     // [10]  L   Indica se o campo é alteravel
	NIL             , ;     // [11]  C   Pasta do campo
	NIL             , ;     // [12]  C   Agrupamento do campo
	NIL				, ;     // [13]  A   Lista de valores permitido do campo (Combo)
	NIL             , ;     // [14]  N   Tamanho maximo da maior opção do combo
	NIL             , ;     // [15]  C   Inicializador de Browse
	.T.             , ;     // [16]  L   Indica se o campo é virtual
	NIL             , ;     // [17]  C   Picture Variavel
	NIL             )       // [18]  L   Indica pulo de linha após o campo


	oStrPAR:RemoveField("PAR_FILIAL")
	oStrPAR:RemoveField("PAR_NCICLO")

	If INCLUI .Or. ALTERA
		oStrPAR:RemoveField("PAR_ALTURA")
		oStrPAR:RemoveField("PAR_TEMPER")
		oStrPAR:RemoveField("PAR_TEMAMO")
		oStrPAR:RemoveField("PAR_DENSID")
		oStrPAR:RemoveField("PAR_DENS20")
		oStrPAR:RemoveField("PAR_FATOR")
		oStrPAR:RemoveField("PAR_VOLAMB")
		oStrPAR:RemoveField("PAR_QUANT")
		oStrPAR:RemoveField("PAR_OP")
		oStrPAR:RemoveField("PAR_QTPROD")
		oStrPAR:RemoveField("PAR_QTTOTA")
		oStrPAR:RemoveField("PAR_PEPERD")
		oStrPAR:RemoveField("PAR_QTPERD")
		oStrPAR:RemoveField("PAR_STATUS")
	EndIf

	oView:AddIncrementField( 'ITENS_PAR', 'PAR_ITEM' )
	oView:CreateHorizontalBox( 'BOX_CABEC', 20)
	oView:CreateHorizontalBox( 'BOX_ITENS_PAR', 40)
	oView:CreateHorizontalBox( 'BOX_ITENS_PC6', 40)
	oView:SetOwnerView('ITENS_PAR','BOX_ITENS_PAR')
	oView:SetOwnerView('ITENS_PC6','BOX_ITENS_PC6')
	oView:SetOwnerView('CABEC','BOX_CABEC')
	oView:EnableTitleView('ITENS_PAR')
	oView:EnableTitleView('ITENS_PC6')
	oView:SetContinuousForm(.T.)

Return oView

 /*/{Protheus.doc} VldPos
	(long_description)
	@type  Function
	@author Gianluca Moreira
	@since 26/06/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function VldPos(oModel)
	Local lRet := .F.

	lRet := U_F04001A0(oModel, .T.)
	If lRet
		lRet := U_F0400125()
	EndIf
	If lRet
		lRet := U_F0400127(oModel)
	EndIf
Return lRet

User Function F04001A0(oModel, lValid)

	Local lRet   := .T.
	Local cQuery := ''
	Local cAlPAQ := ''
	Local cCiclo := ''
	Local uRet   := Nil
	Local nOpcx  := 0

	Default oModel := FWModelActive()
	Default lValid := .F.

	nOpcx := oModel:GetOperation()

	If nOpcx != MODEL_OPERATION_INSERT
		If lValid
			uRet := lRet
		Else
			uRet := cCiclo
		EndIf
		Return ( uRet )
	Endif

	cQuery := " Select Max(PAQ_NCICLO) PAQ_NCICLO From "+RetSqlName('PAQ')+" "
	cQuery += " Where PAQ_FILIAL = '"+FWXFilial('PAQ')+"' And "
	cQuery += "       D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)

	cAlPAQ := MPSysOpenQuery(cQuery)

	If !(cAlPAQ)->(EoF())
		cCiclo := Soma1((cAlPAQ)->PAQ_NCICLO)
		If lValid
			oModel:SetValue('PAQMASTER', 'PAQ_NCICLO', cCiclo)
		EndIf
	EndIf

	(cAlPAQ)->(DbCloseArea())

	If lValid
		uRet := lRet
	Else
		uRet := cCiclo
	EndIf

Return uRet

/*/{Protheus.doc} VldActiv
Impede a alteração ou exclusão de ciclos em andamento ou concluídos
@author Michel Sander
@since 04/07/2019
@version 1.0
@return lActivate, Ativa o modelo?
@param oModel, object, Modelo de dados
@type function
/*/

Static Function VldActiv(oModel)

	Local aAreaPAQ  := PAQ->(GetArea())
	Local aAreaPAR  := PAR->(GetArea())
	Local aAreaPC6  := PC6->(GetArea())
	Local cStatus   := PAQ->PAQ_STATUS
	Local nOper     := oModel:GetOperation()
	Local lActivate := .T.

	If !(nOper == MODEL_OPERATION_UPDATE .Or. nOper == MODEL_OPERATION_DELETE)
		Return .T.
	EndIf
	If IsInCallStack('INSERTREG')
		Return .T.
	EndIf

	If cStatus == '2'
		lActivate := .F.
		cErro := "Registro não pode ser modificado para ciclo em andamento."
		Help(NIL, NIL, "Ação Negada", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
	ElseIf cStatus == '3'
		lActivate := .F.
		cErro := "Registro não pode ser modificado para ciclo encerrado."
		Help(NIL, NIL, "Ação Negada", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
	EndIf

	PAQ->(RestArea(aAreaPAQ))
	PAR->(RestArea(aAreaPAR))
	PC6->(RestArea(aAreaPC6))

Return lActivate

/*/{Protheus.doc} PAQCommit()
Verifica o saldo de estoque no produto no tanque escolhido
@author Michel Sander
@since 04/07/2019
@version 1.0
@return nSaldoSB2
@param oModel, object, Modelo de dados
@type function
/*/

Static Function PAQCommit(oModel)

	Local aAreaPAQ := PAQ->(GetArea())
	Local aAreaPAR := PAR->(GetArea())
	Local nSaldoB2 := 0
	Local cProUso  := oModel:GetValue('PAQMASTER', 'PAQ_CODPRO')
	Local cLocUso  := oModel:GetValue('PAQMASTER', 'PAQ_TANQUE')
	LOCAL nOperac  := oModel:GetOperation()
	Local lAtivo   := .T.

	//BEGIN TRANSACTION

	// Exclui todas as medições do ciclo
	If nOperac == MODEL_OPERATION_DELETE
		PAB->(dbSetOrder(1))
		PAR->(dbSetOrder(1))
		If PAR->(dbSeek(PAQ->PAQ_FILIAL+PAQ->PAQ_NCICLO))
			While PAR->(!Eof()) .And. PAR->PAR_FILIAL+PAR->PAR_NCICLO == PAQ->PAQ_FILIAL+PAQ->PAQ_NCICLO
				If PAB->(dbSeek(PAR->PAR_FILIAL+PAR->PAR_TANQUE))
					While PAB->(!Eof()) .And. PAB->PAB_FILIAL+PAB->PAB_TANQUE == PAR->PAR_FILIAL+PAR->PAR_TANQUE
						If PAB->PAB_NCICLO == PAR->PAR_NCICLO
							Reclock("PAB",.F.)
							PAB->(dbDelete())
							PAB->(MsUnlock())
						ENDIF
						PAB->(dbSkip())
					EndDo
				ENDIF
				PAR->(dbSkip())
			EndDo
		EndIf

	EndIf

	//END TRANSACTION

	PAQ->(RestArea(aAreaPAQ))
	PAR->(RestArea(aAreaPAR))

Return ( lAtivo )

/*/{Protheus.doc} LegPar
Cria a legenda do grid de itens do ciclo
@author Michel Sander
@since 04/07/2019
@version 1.0
@return 
@param oModel, object, Modelo de dados
@type function
/*/

Static Function LegPAR(cParamIXB)

	LOCAL cLegenda  := ""

	If INCLUI
		If cParamIXB == 1
			cLegenda := 'BR_VERDE'
		else
			cLegenda := "Aguardando"
		EndIf
	Else
		If PAQ->PAQ_STATUS == '3'
			If cParamIXB == 1
				cLegenda := 'BR_VERMELHO'
			else
				cLegenda := "Finalizado"
			EndIf
		ElseIf PAR->PAR_STATUS == 'P'
			If cParamIXB == 1
				cLegenda := 'BR_AMARELO'
			else
				cLegenda := "Apto. Parcial"
			EndIf
		Else
			If cParamIXB == 1
				cLegenda := 'BR_VERDE'
			else
				cLegenda := "Aguardando"
			EndIf
		EndIf 
	EndIf 

Return ( cLegenda )

/*/{Protheus.doc} CreateTrigger
Cria os gatilhos dos campos de edio
@author Michel Sander
@since 04/07/2019
@version 1.0
@return nSaldoSB2
@param oModel, object, Modelo de dados

@type function
/*/

Static Function CreateTrigger(cDominio, cOrdem)

	Local aAux := {}
	Local nCntFor := 0

	Default cOrdem := '01'

	If cDominio == "PAQ_CODPRO" .And. cOrdem == '01'
		aAux := FwStruTrigger(;
			"PAQ_CODPRO" ,; // Campo Dominio
		"PAQ_DESCR" ,; // Campo de Contradominio
		"SB1->B1_DESC",; // Regra de Preenchimento
		.T. ,; // Se posicionara ou nao antes da execucao do gatilhos
		"SB1" ,; // Alias da tabela a ser posicionada
		1 ,; // Ordem da tabela a ser posicionada
		"xFilial('SB1')+M->PAQ_CODPRO" ,; // Chave de busca da tabela a ser posicionada
		NIL ,; // Condicao para execucao do gatilho
		"01" ) // Sequencia do gatilho (usado para identificacao no caso de erro)
	EndIf

	If cDominio == "PAQ_CODPRO"  .And. cOrdem == '02'
		aAux := FwStruTrigger(;
			"PAQ_CODPRO" ,; // Campo Dominio
		"PAQ_LOCAL" ,; // Campo de Contradominio
		"AllTrim(GetMv('MV_X_LBASE'))",; // Regra de Preenchimento
		.F. ,; // Se posicionara ou nao antes da execucao do gatilhos
		Nil ,; // Alias da tabela a ser posicionada
		0 ,; // Ordem da tabela a ser posicionada
		NIL ,; // Chave de busca da tabela a ser posicionada
		NIL ,; // Condicao para execucao do gatilho
		"02" ) // Sequencia do gatilho (usado para identificacao no caso de erro)
	EndIf

	If cDominio == "PAQ_TANQUE"  .And. cOrdem == '01'
		aAux := FwStruTrigger(;
			"PAQ_TANQUE" ,; // Campo Dominio
		"PAQ_QUANT" ,; // Campo de Contradominio
		"PC7->PC7_QUANT",; // Regra de Preenchimento
		.T. ,; // Se posicionara ou nao antes da execucao do gatilhos
		"PC7" ,; // Alias da tabela a ser posicionada
		1 ,; // Ordem da tabela a ser posicionada
		"xFilial('PC7')+M->PAQ_CODPRO+M->PAQ_TANQUE" ,; // Chave de busca da tabela a ser posicionada
		NIL ,; // Condicao para execucao do gatilho
		"01" ) // Sequencia do gatilho (usado para identificacao no caso de erro)
	EndIf

	If cDominio == "PAR_CODPRO"  .And. cOrdem == '01'
		aAux := FwStruTrigger(;
			"PAR_CODPRO" ,; // Campo Dominio
		"PAR_DESCR" ,; // Campo de Contradominio
		"SB1->B1_DESC",; // Regra de Preenchimento
		.T. ,; // Se posicionara ou nao antes da execucao do gatilhos
		"SB1" ,; // Alias da tabela a ser posicionada
		1 ,; // Ordem da tabela a ser posicionada
		"xFilial('SB1')+M->PAR_CODPRO" ,; // Chave de busca da tabela a ser posicionada
		NIL ,; // Condicao para execucao do gatilho
		"01" ) // Sequencia do gatilho (usado para identificacao no caso de erro)

	EndIf

	If cDominio == "PAR_CODPRO"  .And. cOrdem == '02'
		aAux := FwStruTrigger(;
			"PAR_CODPRO" ,; // Campo Dominio
		"PAR_LOCAL" ,; // Campo de Contradominio
		"FwFldGet('PAQ_LOCAL')",; // Regra de Preenchimento
		.F. ,; // Se posicionara ou nao antes da execucao do gatilhos
		NIL ,; // Alias da tabela a ser posicionada
		0 ,; // Ordem da tabela a ser posicionada
		NIL ,; // Chave de busca da tabela a ser posicionada
		NIL ,; // Condicao para execucao do gatilho
		"02" ) // Sequencia do gatilho (usado para identificacao no caso de erro)

	EndIf

Return aAux

/*/{Protheus.doc} F0400101
Tela de apontamento e medição
@author Michel Sander
@since 04/07/2019
@version 1.0
@return 
@param 
@type function
/*/

User Function F0400101()

	LOCAL cDataCiclo := PAQ->PAQ_DATA
	LOCAL cMateria   := PAQ->PAQ_CODPRO
	LOCAL cDescrMp   := Posicione("SB1",1,xFilial("SB1")+cMateria,"B1_DESC")
	LOCAL cUnidade   := PAQ->PAQ_TANQUE
	LOCAL aButProd   := {}
	LOCAL aHeaderPAR := {}
	LOCAL aColsPAR   := {}
	LOCAL nUsado     := 0
	LOCAL nOpca 	  := 0
	LOCAL aMedicoes  := {}
	Local nCntFor := 0

	PRIVATE cNumCiclo  := PAQ->PAQ_NCICLO
	PRIVATE nQtdeCons  := PAQ->PAQ_CONSU
	PRIVATE oQtdeCons
	PRIVATE nQtdeMat   := PAQ->PAQ_QUANT
	PRIVATE oQtdeMat
	PRIVATE nQtdePrev  := PAQ->PAQ_QTPREV
	PRIVATE oQtdePrev
	PRIVATE nQtdePerd  := PAQ->PAQ_PERDA
	PRIVATE oQtdePerda

	//Montagem do aHeader
	dbSelectArea("SX3")
	dbSetOrder(1)
	MsSeek("PAR")
	While ( !Eof() .And. SX3->X3_ARQUIVO == "PAR" )
		If AllTrim(SX3->X3_CAMPO)=="PAR_NCICLO"
			SX3->(dbSkip())
			Loop
		EndIf
		If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL )
			nUsado++
			Aadd(aHeaderPAR,{ TRIM(X3Titulo()),;
				TRIM(SX3->X3_CAMPO),;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_VALID,;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_F3,;
				SX3->X3_CONTEXT } )
		EndIf
		SX3->(dbSkip())
	EndDo

	//Montagem do aCols
	PAR->(dbSetOrder(1))
	PAR->(dbSeek(xFilial()+cNumCiclo))
	cTrab  := "PAR"
	bWhile := {|| xFilial("PAR") == PAR->PAR_FILIAL .And.;
		cNumCiclo      == PAR->PAR_NCICLO }

	While ( PAR->(!Eof()) .And. Eval(bWhile) )
		AADD(aColsPAR,Array(nUsado+1))
		For nCntFor	:= 1 To nUsado
			If ( aHeaderPAR[nCntFor][10] != "V" )
				aColsPAR[Len(aColsPAR)][nCntFor] := PAR->(FieldGet(FieldPos(aHeaderPAR[nCntFor][2])))
			Else
				aColsPAR[Len(aColsPAR)][nCntFor] := PAR->(CriaVar(aHeaderPAR[nCntFor][2]))
			EndIf
		Next nCntFor
		aColsPAR[Len(aColsPAR)][3]        := SubStr(Posicione("SB1",1,xFilial("SB1")+aColsPAR[Len(aColsPAR)][2],"B1_DESC"),1,25)
		aColsPAR[Len(aColsPAR)][nUsado+1] := .F.
		PAR->(dbSkip())
	EndDo

	//Posição da tela inicial
	nLin  := 45
	nCol1 := 10
	nCol2 := 95

	//Cabeçalho do ciclo
	DEFINE MSDIALOG oDlg01 TITLE OemToAnsi("Apontamento de Produção") FROM 0,0 TO 510,1300 PIXEL of oMainWnd PIXEL //300,400 PIXEL of oMainWnd PIXEL
	@ nLin-10,nCol1-05 TO nLin+65,nCol1+635 LABEL " Ciclo de Produção "  OF oDlg01 PIXEL
	@ nLin+3, nCol1	SAY oTexto10 Var 'No. Ciclo'    			   SIZE 100,10 PIXEL
	oTexto10:oFont := TFont():New('Arial',,18,,.T.,,,,.T.,.F.)
	@ nLin+3, nCol2-45	SAY oTexto12 Var 'Data'    				   SIZE 100,10 PIXEL
	oTexto12:oFont := TFont():New('Arial',,18,,.T.,,,,.T.,.F.)
	@ nLin+3, nCol1+110	SAY oTexto16 Var 'Volume Previsto Mat.Prima' SIZE 100,10 PIXEL
	oTexto16:oFont := TFont():New('Arial',,18,,.T.,,,,.T.,.F.)

	@ nLin+10, nCol2+318 SAY oTexto16 Var 'Volume Mat. Prima 20ºC' SIZE 100,10 PIXEL
	oTexto16:oFont := TFont():New('Arial',,18,,.T.,,,,.T.,.F.)
	@ nLin+7, nCol2+410 MSGET oQtdeMat VAR nQtdeMat Picture PesqPict("PAQ","PAQ_QUANT") SIZE 130,12  WHEN .F. PIXEL
	oQtdeMat:oFont := TFont():New('Courier New',,20,,.T.,,,,.T.,.F.)
	@ nLin+26, nCol2+318 SAY oTexto17 Var 'Volume Consumido 20ºC' SIZE 100,10 PIXEL
	oTexto17:oFont := TFont():New('Arial',,18,,.T.,,,,.T.,.F.)
	@ nLin+24, nCol2+410 MSGET oQtdeCons VAR nQtdeCons Picture PesqPict("PAQ","PAQ_CONSU") SIZE 130,12  WHEN .F. PIXEL
	oQtdeCons:oFont := TFont():New('Courier New',,20,,.T.,,,,.T.,.F.)
	@ nLin+43, nCol2+318 SAY oTexto18 Var 'Volume de Perda 20ºC' SIZE 100,10 PIXEL
	oTexto18:oFont := TFont():New('Arial',,18,,.T.,,,,.T.,.F.)
	@ nLin+41, nCol2+410 MSGET oQtdePerda VAR nQtdePerd Picture PesqPict("PAQ","PAQ_PERDA") SIZE 130,12 WHEN .F. PIXEL
	oQtdePerda:oFont := TFont():New('Courier New',,20,,.T.,,,,.T.,.F.)
	nLin += 15
	@ nLin-2, nCol1     MSGET oCiclo     VAR cNumCiclo  SIZE 30,12  WHEN .F. PIXEL
	oCiclo:oFont := TFont():New('Courier New',,18,,.T.,,,,.T.,.F.)
	@ nLin-2, nCol2-45  MSGET oDataCiclo VAR cDataCiclo SIZE 60,12  WHEN .F. PIXEL
	oDataCiclo:oFont := TFont():New('Courier New',,18,,.T.,,,,.T.,.F.)
	@ nLin-2, nCol1+110 MSGET oQtdePrev  VAR nQtdePrev Picture PesqPict("PAQ","PAQ_QTPREV") SIZE 130,12  WHEN .F. PIXEL
	oQtdePrev:oFont := TFont():New('Courier New',,18,,.T.,,,,.T.,.F.)

	nLin +=20
	@ nLin, nCol1	SAY oTexto13 Var 'Matéria Prima'           SIZE 100,10 PIXEL
	oTexto13:oFont := TFont():New('Arial',,18,,.T.,,,,.T.,.F.)
	@ nLin, nCol1+85	SAY oTexto14 Var 'Descrição'               SIZE 120,10 PIXEL
	oTexto14:oFont := TFont():New('Arial',,18,,.T.,,,,.T.,.F.)
	@ nLin, nCol2+260	SAY oTexto15 Var 'Unid. Prod.'          SIZE 100,10 PIXEL
	oTexto15:oFont := TFont():New('Arial',,18,,.T.,,,,.T.,.F.)

	nLin += 10
	@ nLin, nCol1 MSGET oMateria   VAR cMateria   SIZE 80,12 WHEN .F. PIXEL
	oMateria:oFont := TFont():New('Courier New',,18,,.T.,,,,.T.,.F.)
	@ nLin, nCol1+85 MSGET oDescrMp   VAR cDescrMp   SIZE 250,12 WHEN .F. PIXEL
	oDescrMp:oFont := TFont():New('Courier New',,18,,.T.,,,,.T.,.F.)
	@ nLin, nCol2+260 MSGET oUnidade   VAR cUnidade   SIZE 50,12  WHEN .F. PIXEL
	oUnidade:oFont := TFont():New('Courier New',,18,,.T.,,,,.T.,.F.)

	oGetDados  := (MsNewGetDados():New( nLin+30, 05 , 245 ,645,Nil ,"AlwaysTrue" ,"AlwaysTrue", /*inicpos*/,/*aCpoHead*/,/*nfreeze*/,9999 ,/*"U_Ffieldok()"*/,/*superdel*/,/*delok*/,oDlg01,aHeaderPAR,aColsPAR))
	oGetDados:oBrowse:Refresh()
	nLin += 190

	//Botões de controle
	aButtons := {}
	nOpcA	 := 0
	If !PAQ->PAQ_STATUS == "3"
		Aadd(aButtons	, {'MEDIÇÃO',   		{ || MedicTanq(@oGetDados, @aMedicoes)},OemToAnsi("Medição")})
		Aadd(aButtons	, {'ALIMENTAÇÃO',		{ || aMedicoes := U_F0400102(oGetDados:aHeader,oGetDados:aCols,oGetDados:nAt,,1),;
			AtuItens(@aMedicoes,oGetDados:nAt),;
			nQtdeMat  := PAQ->PAQ_QUANT,;
			oQtdeMat:Refresh(),;
			oGetDados:oBrowse:Refresh() }, OemToAnsi("Alimentação")})
		Aadd(aButtons	, {'Apto. PARCIAL',	{ || fParcial(@oGetDados,oGetDados:nAt,@cNumCiclo)},OemToAnsi("Parcial")})
		Aadd(aButtons	, {'FINALIZA CICLO', { || Processa({||U_F0400105(@oGetDados,oGetDados:nAt,@cNumCiclo)})},OemToAnsi("Finalizar Ciclo")})
	ENDIF

	ACTIVATE MSDIALOG oDlg01 ON INIT EnchoiceBar(oDlg01,{||nOpcA:=1,oDlg01:End()},{||oDlg01:End()},,aButtons, , ,.F.,.F.,.F.,.F.,.F.)

Return

Static Function MedicTanq(oGetDados, aMedicoes)
	Local lOk := .T.
	Local nPosV20  := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])== "PAR_QUANT" })

	If !Empty(oGetDados:aCols[oGetDados:nAt, nPosV20])
		lOk := .F.
		Help(,,"MedicTanq",,"Existe uma medição realizada, porém não foi apontada Ordem de Produção Parcial.", 1, 0,;
			,,,,,{"Realize o apontamento parcial."})
	EndIf

	If lOk
		aMedicoes := U_F0400102(oGetDados:aHeader,oGetDados:aCols,oGetDados:nAt)
		AtuItens(@aMedicoes,oGetDados:nAt)
		oGetDados:oBrowse:Refresh()
	EndIf

Return

/*/{Protheus.doc} AtuItens()
Atualiza a linha de dados do ciclo com o retorno da medição

@author Michel Sander
@since 11/07/2019
@version 1.0
@return 
@param 
@type function
/*/

Static Function AtuItens(aMedicoes, nPosGrid)

	LOCAL lAtuOP  := .T.
	LOCAL lAtItem := .T.
	DEFAULT aMedicoes := {}
	DEFAULT nPosGrid  := 0

	PRIVATE nPosAlt := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_ALTURA"})
	PRIVATE nPosTem := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_TEMPER"})
	PRIVATE nPosAmo := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_TEMAMO"})
	PRIVATE nPosDen := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_DENSID"})
	PRIVATE nPosD20 := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_DENS20"})
	PRIVATE nPosFat := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_FATOR"})
	PRIVATE nPosVam := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_VOLAMB"})
	PRIVATE nPosV20 := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_QUANT"})
	PRIVATE nPosSC2 := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_OP"})
	PRIVATE nPosQTP := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_QTPROD"})
	PRIVATE nPosT20 := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_QTTOTA"})
	PRIVATE nPosQPE := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_QTPERD"})
	PRIVATE nPosLoc := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_LOCAL"})

	If Len(aMedicoes) > 0
		oGetDados:aCols[oGetDados:nAt,nPosAlt] := aMedicoes[1]   // Altura
		oGetDados:aCols[oGetDados:nAt,nPosTem] := aMedicoes[2]   // Temperatura do Tanque
		oGetDados:aCols[oGetDados:nAt,nPosAmo] := aMedicoes[3]   // Temperatura da Amostra
		oGetDados:aCols[oGetDados:nAt,nPosDen] := aMedicoes[4]   // Densidade Ambiente
		oGetDados:aCols[oGetDados:nAt,nPosD20] := aMedicoes[5]   // Densidade 20º
		oGetDados:aCols[oGetDados:nAt,nPosFat] := aMedicoes[6]   // Fator de Conversão
		oGetDados:aCols[oGetDados:nAt,nPosVam] := aMedicoes[7]   // Volume Ambiente
		oGetDados:aCols[oGetDados:nAt,nPosV20] := Abs(aMedicoes[8])   // Var. Volume 20º
		oGetDados:aCols[oGetDados:nAt,nPosSC2] := aMedicoes[9]   // Número da OP
		oGetDados:aCols[oGetDados:nAt,nPosLoc] := aMedicoes[10]   // Armazem Padrão
		oGetDados:Refresh()

		// Atualiza o item do ciclo
		U_F0400109(@oGetDados, oGetDados:nAT, @cNumCiclo, .T.)
	EndIf

Return

/*/{Protheus.doc} fParcial
Aciona o apontamento de produção

@author Michel Sander
@since 11/07/2019
@version 1.0
@return 
@param oGetDados, cNumCiclo
@type function
/*/

Static Function fParcial(oGetDados, nLinha, cNumCiclo)

	LOCAL cPerg    := ""
	LOCAL _nPosPro := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_CODPRO"})

	If Empty(cTmProd)
		cErro := "Tipo de movimento de produção não preenchido no parâmetro FS_C040011."
		Help(NIL, NIL, "Não Permitido", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
		Return
	Endif

	cPerg := "Confirma o apontamento de produção do Item?"+CRLF+CRLF
	cPerg += "Item "+StrZero(nLinha,4)+" Produto "+oGetDados:aCols[nLinha,_nPosPro]
	If MsgYesNo(cPerg,"Aponta ITEM")
		Processa( { || U_F0400103(@oGetDados,nLinha,@cNumCiclo) } )
	ENDIF

	oGetDados:oBrowse:Refresh()
Return

/*/{Protheus.doc} F0400103
Apontamento parcial do Item posicionado
chamada pela rotina principal F0400100 no botão PARCIAL
@author Michel Sander
@since 11/07/2019
@version 1.0
@return 
@param 
@type function
/*/

User Function F0400103(oGetDados, nPosLinha, cNumCiclo)

	LOCAL _nPosItem := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_ITEM"})
	LOCAL _nPosTank := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_TANQUE"})
	LOCAL _nPosQT   := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_QUANT"})
	LOCAL _nPosOP   := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_OP"})
	LOCAL _nPosAlt  := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_ALTURA"})
	LOCAL _nPosTem  := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_TEMPER"})
	LOCAL _nPosAmo  := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_TEMAMO"})
	LOCAL _nPosDen  := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_DENSID"})
	LOCAL _nPosD20  := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_DENS20"})
	LOCAL _nPosFat  := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_FATOR"})
	LOCAL _nPosVam  := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_VOLAMB"})
	LOCAL _nPosV20  := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_QUANT"})
	LOCAL _nPosSC2  := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_OP"})
	LOCAL _nPosQTP  := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_QTPROD"})
	LOCAL _nPosT20  := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_QTTOTA"})
	LOCAL _nPosPPE  := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_PEPERD"})
	LOCAL _nPosQPE  := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_QTPERD"})
	LOCAL aSaldoMat := {}
	LOCAL cGeraOP   := ""
	LOCAL cLoteApo  := ""
	LOCAL nX        := 0
	LOCAL lAponta   := .T.
	LOCAL lAbreOp   := .T.
	LOCAL lTudoOk   := .T.
	LOCAL nSomaQT   := 0
	LOCAL cErro     := ""
	LOCAL nProcessa := 5

	ProcRegua(nProcessa)

	PAR->(dbSetOrder(2))
	SB1->(dbSetOrder(1))
	PC6->(dbSetOrder(1))

	// Aponta produção parcial do item posicionado
	If PAR->(dbSeek(xFilial()+cNumCiclo+oGetDados:aCols[nPosLinha,_nPosItem]+oGetDados:aCols[nPosLinha,_nPosTank]))

		If !SB1->(dbSeek(xFilial()+PAR->PAR_CODPRO))
			cErro := "Produto "+PAR->PAR_CODPRO+" não existe no cadastro de produtos"
			Help(NIL, NIL, "F0400103", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
			Return .F.
		EndIf

		// Não aponta registro sem medição
		If PAR->PAR_QUANT == 0
			cErro := "Não será possível apontar registro sem medição!"
			Help(NIL, NIL, "F0400103", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
			Return .F.
		EndIf

		BEGIN TRANSACTION
			// Verifica Produção
			// Abre orde de produção
			IncProc('Abrindo OP...')
			lAbreOp := U_F0400111(GetNumSC2(),;
				"01",;
				"001",;
				PAR->PAR_CODPRO,;
				PAR->PAR_LOCAL,;
				PAR->PAR_QUANT,;
				SB1->B1_UM,;
				SB1->B1_SEGUM,;
				dDataBase,;
				dDataBase+360,;
				SB1->B1_REVATU,;
				"F",;
				dDataBase,;
				"S",;
				PAR->PAR_TANQUE)
			If !lAbreOp
				DisarmTransaction()
				Break
			Else
				lTudoOk := .T.
			EndIf

			If lTudoOk .And. lAbreOP
				Reclock("PAR",.F.)
				PAR->PAR_OP := SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN
				PAR->PAR_STATUS := 'P'
				PAR->(MsUnlock())
				oGetDados:aCols[oGetDados:nAt,_nPosOP] := PAR->PAR_OP
				oGetDados:Refresh()
				IncProc('Ajuste de Empenho...')
				lAltEmp := U_F0400115(PAR->PAR_OP,PAR->PAR_CODPRO,PAQ->PAQ_TANQUE,PAR->PAR_LOCAL,,PAR->PAR_QUANT)
				If !lAltEmp
					DisarmTransaction()
					lTudoOk := .F.
					Break
				EndIf

				//Atualiza Apontamentos de produção
				If !PC6->(dbSeek(PAR->PAR_FILIAL+PAR->PAR_NCICLO+PAR->PAR_ITEM+PAR->PAR_TANQUE+PAR->PAR_OP))
					Reclock("PC6",.T.)
					PC6->PC6_FILIAL := PAR->PAR_FILIAL
					PC6->PC6_NCICLO := PAR->PAR_NCICLO
					PC6->PC6_ITEM   := PAR->PAR_ITEM
					PC6->PC6_CODPRO := PAR->PAR_CODPRO
					PC6->PC6_TANQUE := PAR->PAR_TANQUE
					PC6->PC6_OP     := PAR->PAR_OP
					PC6->PC6_QUANT  := PAR->PAR_QUANT
					PC6->PC6_LOCAL  := PAR->PAR_LOCAL
					PC6->(MsUnlock())
				EndIf
			EndIf

			// Posiciona na Ordem de Produção
			SC2->(dbSetOrder(1))
			SC2->(dbSeek(xFilial()+PAR->PAR_OP))
			SB1->(dbSeek(xFilial()+PAR->PAR_CODPRO))

			//Número de lote disponível
			PAA->(dbSetOrder(1))
			If PAA->(dbSeek(xFilial()+PAR->PAR_TANQUE))
				If Empty(PAA->PAA_PRXLOT)
					Reclock("PAA",.F.)
					PAA->PAA_PRXLOT := U_F0402802(PAR->PAR_TANQUE)
					PAA->(MsUnlock())
				EndIf
				cLoteApo := PAA->PAA_PRXLOT
			EndIf

			// Aponta ordem de produção
			IncProc('Apontamento...')
			lAponta := U_F0400112(cTmProd,;
				PAR->PAR_CODPRO,;
				SB1->B1_UM,;
				PAR->PAR_QUANT,;
				0.00,;
				PAR->PAR_OP,;
				PAR->PAR_TANQUE,;
				dDataBase,;
				'T',;
				cLoteApo,;
				3,;
				PAR->PAR_NCICLO,;
				PAR->PAR_LOCAL)
			If !lAponta
				DisarmTransaction()
				Break
			ENDIF

			// Ajusta os totais
			Reclock("PAR",.F.)
			PAR->PAR_QTPROD := PAR->PAR_QUANT
			PAR->PAR_QTTOTA += PAR->PAR_QTPROD
			PAR->(MsUnlock())
			nSomaQT += PAR->PAR_QTTOTA

			// Limpa os dados da medição apontada
			oGetDados:aCols[oGetDados:nAt,_nPosAlt] := 0  // Altura
			oGetDados:aCols[oGetDados:nAt,_nPosTem] := 0  // Temperatura do Tanque
			oGetDados:aCols[oGetDados:nAt,_nPosAmo] := 0  // Temperatura da Amostra
			oGetDados:aCols[oGetDados:nAt,_nPosDen] := 0  // Densidade Ambiente
			oGetDados:aCols[oGetDados:nAt,_nPosD20] := 0  // Densidade 20º
			oGetDados:aCols[oGetDados:nAt,_nPosFat] := 0  // Fator de Conversão
			oGetDados:aCols[oGetDados:nAt,_nPosVam] := 0  // Volume Ambiente
			oGetDados:aCols[oGetDados:nAt,_nPosV20] := 0  // Volume 20ºC
			oGetDados:aCols[oGetDados:nAt,_nPosQTP] := PAR->PAR_QTPROD   // Volume Prod. 20ºC
			oGetDados:aCols[oGetDados:nAt,_nPosT20] := PAR->PAR_QTTOTA	// Volume Prod. Total 20ºC_

			// Atualiza o item do ciclo que foi apontado
			U_F0400109(@oGetDados, oGetDados:nAT, @cNumCiclo, .F.)

			Reclock("PAQ",.F.)
			aSaldoMat := U_F0400106(PAQ->PAQ_TANQUE, PAQ->PAQ_CODPRO, .F.)
			PAQ->PAQ_QUANT  := aSaldoMat[2]
			PAQ->PAQ_CONSU  := U_F0400123(PAQ->PAQ_NCICLO)
			PAQ->PAQ_STATUS := "2"
			PAQ->(MsUnlock())
			nQtdeCons := PAQ->PAQ_CONSU
			nQtdeMat  := PAQ->PAQ_QUANT
			oQtdeCons:Refresh()
			oQtdeMat:Refresh()

			IncProc('Libera tanque...')
			PAA->(dbSetOrder(1))
			If PAA->(dbSeek(xFilial()+PAR->PAR_TANQUE))
				Reclock("PAA",.F.)
				PAA->PAA_STATUS := 'A'
				PAA->(MsUnlock())
			EndIf

			cErro := "Apontamento parcial concluído!"+CRLF+CRLF
			cErro += "Total Programado = " + TransForm(PAQ->PAQ_QTPREV,"@E 999,999,999.99")+CRLF
			cErro += "Total Produzido  = " + TransForm(PAQ->PAQ_CONSU,"@E 999,999,999.99")+CRLF
			cErro += "Total de Perdas  = " + TransForm(PAQ->PAQ_PERDA,"@E 999,999,999.99")
			Help(NIL, NIL, "Produção OK", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})

		END TRANSACTION

	EndIf

	oGetDados:Refresh()

Return nil

/*/{Protheus.doc} F0400104
Estorno de apontamento de produção via ciclo de combustível
chamada pela rotina principal F0400100 no botão ESTORNAR
@author Michel Sander
@since 11/07/2019
@version 1.0
@return 
@param 
@type function 
/*/

User function F0400104()

	LOCAL lEstCiclo := .T.
	LOCAL aSaldoMat := 0

	If !MsgYesNo("Deseja estornar os apontamentos de produção do ciclo No. "+PAQ->PAQ_NCICLO+"?","ESTORNO")
		Return .T.
	EndIf

	// Estorna todas as produções do ciclo
	MsgRun("Estornando produções...","MATA250", { || lEstCiclo := U_F0400113() } )

	If lEstCiclo
		aSaldoMat := U_F0400106(PAQ->PAQ_TANQUE, PAQ->PAQ_CODPRO, .F.)
		Reclock("PAQ",.F.)
		PAQ->PAQ_QUANT  := aSaldoMat[2]
		PAQ->(MsUnlock())
	EndIf

Return ( lEstCiclo )

/*/{Protheus.doc} F0400105
Finaliza o ciclo com Apontamento de produção dos itens e encerramento da OP

@author Michel Sander
@since 11/07/2019
@version 1.0
@return 
@param aCabec, aLinha, nPoslinha
@type function
/*/

User Function F0400105(oGetDados,nPosLinha, cNumCiclo)

	LOCAL _nPosItem := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_ITEM"})
	LOCAL _nPosTank := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_TANQUE"})
	LOCAL _nPosQT   := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_QUANT"})
	LOCAL _nPosOP   := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_OP"})
	LOCAL _nPosAlt  := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_ALTURA"})
	LOCAL _nPosTem  := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_TEMPER"})
	LOCAL _nPosAmo  := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_TEMAMO"})
	LOCAL _nPosDen  := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_DENSID"})
	LOCAL _nPosD20  := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_DENS20"})
	LOCAL _nPosFat  := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_FATOR"})
	LOCAL _nPosVam  := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_VOLAMB"})
	LOCAL _nPosV20  := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_QUANT"})
	LOCAL _nPosSC2  := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_OP"})
	LOCAL _nPosQTP  := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_QTPROD"})
	LOCAL _nPosT20  := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_QTTOTA"})
	LOCAL _nPosPPE  := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_PEPERD"})
	LOCAL _nPosQPE  := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_QTPERD"})
	Local _nPosStat := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_STATUS"})
	Local _nPosPro  := ASCAN( oGetDados:aHeader, { |x| AllTrim(x[2])=="PAR_CODPRO"})
	LOCAL cGeraOP   := ""
	LOCAL cLoteApo  := ""
	LOCAL nX        := 0
	LOCAL lAponta   := .T.
	LOCAL lAbreOp   := .T.
	LOCAL nSomaQT   := 0
	LOCAL lTudoOk   := .T.
	LOCAL lAltEmp   := .T.
	LOCAL lPerda    := .T.
	LOCAL cErro     := ""
	LOCAL nSomPerda := 0
	LOCAL nCalcPerd := 0
	LOCAL cTpMov    := SuperGetMV("FS_C010393",.F.,"")
	LOCAL aLotePerda:= {}
	LOCAL nProcessa := 6
	LOCAL nValUso   := 0
	LOCAL cMVA685OPE:=AllTrim(GetMv("MV_A685OPE"))
	Local nQ
	Local nPerc1    := 0
	Local nPerc2    := 0
	Local nPerc3    := 0
	Local aSaldoFin := {}

	ProcRegua(nProcessa)

	SC2->(dbSetOrder(1)) //C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD
	PAR->(dbSetOrder(2)) //PAR_FILIAL+PAR_NCICLO
	SB1->(dbSetOrder(1)) //B1_FILIAL+B1_COD
	PC6->(DbSetOrder(1)) //PC6_FILIAL+PC6_NCICLO+PC6_ITEM+PC6_TANQUE+PC6_OP

	If Empty(cTpMov)
		Help( ,, 'Não permitido',, 'Parâmetro FS_C010393 não encontrado ou sem código de movimento para requisição de estoque configurado.', 1, 0, , , , , , {'Contate o administrador de sistema para configuração do parâmetro citado.'})
		Return
	EndIf

	If Empty(cMVA685OPE) .Or. cMVA685OPE <> "S"
		Help( ,, 'Não permitido',, 'O Parâmetro MV_A685OPE deve estar com conteúdo igual a S, para que as requisições de perda possam ser realizadas após apontamento de produção.', 1, 0, , , , , , {'Contate o administrador de sistema para configuração do parâmetro citado.'})
		Return
	EndIf

	For nQ := 1 to Len(oGetDados:aCols)
		If Empty(oGetDados:aCols[nQ, _nPosOP])
			Help( ,, 'F0400105',, 'O produto '+oGetDados:aCols[nQ, _nPosPro]+' no Tanque '+oGetDados:aCols[nQ, _nPosTank]+' sem apontamento parcial.', 1, 0,;
				,,,,,{'Realize o apontamento parcial de produção.'})
			Return
		EndIf
	NEXT nQ

	BEGIN TRANSACTION

		// Total consumido
		nSomaQT := U_F0400123(PAQ->PAQ_NCICLO)
		nCalcPerd := PAQ->PAQ_QUANT
		oQtdePerda:Refresh()

		// Cálculo da perda por armazém
		For nQ := 1 to Len(oGetDados:aCols)
			//nValUso := If(oGetDados:aCols[nQ,_nPosV20]==0,oGetDados:aCols[nQ,_nPosT20],oGetDados:aCols[nQ,_nPosV20])
			nValUso := U_F0400123(PAQ->PAQ_NCICLO, oGetDados:aCols[nQ, _nPosItem])
			oGetDados:aCols[nQ,_nPosPPE] := nValUso / nSomaQT
			oGetDados:aCols[nQ,_nPosQPE] := oGetDados:aCols[nQ,_nPosPPE] * nCalcPerd
		NEXT

		For nX := 1 to Len(oGetDados:aCols)

			ProcRegua(nProcessa)
			If PAR->(dbSeek(xFilial()+cNumCiclo+oGetDados:aCols[nx,_nPosItem]+oGetDados:aCols[nx,_nPosTank]))

				lTudoOk := .T.

				// Rateio da perda pelos itens
				Reclock("PAR",.F.)
				PAR->PAR_QTPERD := oGetDados:aCols[nX,_nPosQPE]
				PAR->PAR_PEPERD := oGetDados:aCols[nX,_nPosPPE]
				PAR->(MsUnlock())
				nSomPerda += PAR->PAR_QTPERD

				IF Empty(PAR->PAR_OP)

					// Abre ordem de produção
					IncProc('Abrindo OP...')
					SB1->(dbSeek(xFilial()+PAR->PAR_CODPRO))
					lAbreOp := U_F0400111(GetNumSC2(),;
						"01",;
						"001",;
						PAR->PAR_CODPRO,;
						PAR->PAR_LOCAL,;
						PAR->PAR_QUANT + PAR->PAR_QTPERD,;
						SB1->B1_UM,;
						SB1->B1_SEGUM,;
						dDataBase,;
						dDataBase+360,;
						SB1->B1_REVATU,;
						"F",;
						dDataBase,;
						"S",;
						PAR->PAR_TANQUE)
					If !lAbreOp
						DisarmTransaction()
						lTudoOk := .F.
						Exit
					EndIf

					Reclock("PAR",.F.)
					PAR->PAR_OP := SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN
					PAR->(MsUnlock())
					oGetDados:aCols[nx,_nPosOP] := PAR->PAR_OP
					oGetDados:Refresh()

					// Posiciona na Ordem de Produção
					SC2->(dbSeek(xFilial()+PAR->PAR_OP))
					SB1->(dbSeek(xFilial()+PAR->PAR_CODPRO))

					//Número de lote disponível
					PAA->(dbSetOrder(1))
					If PAA->(dbSeek(xFilial()+PAR->PAR_TANQUE))
						If Empty(PAA->PAA_PRXLOT)
							Reclock("PAA",.F.)
							PAA->PAA_PRXLOT := U_F0402802(PAR->PAR_TANQUE)
							PAA->(MsUnlock())
						EndIf
						cLoteApo := PAA->PAA_PRXLOT
					EndIf

					// Aponta ordem de produção
					IncProc('Apontamento...')
					lAponta := U_F0400112(cTmProd,;
						PAR->PAR_CODPRO,;
						SB1->B1_UM,;
						PAR->PAR_QUANT,;
						PAR->PAR_QTPERD,;
						PAR->PAR_OP,;
						PAR->PAR_TANQUE,;
						dDataBase,;
						'T',;
						cLoteApo,;
						3,;
						PAR->PAR_NCICLO,;
						PAR->PAR_LOCAL)
					If !lAponta
						DisarmTransaction()
						lTudoOk := .F.
						Exit
					ENDIF

					// Ajusta os totais
					Reclock("PAR",.F.)
					PAR->PAR_QTPROD := PAR->PAR_QUANT
					PAR->PAR_QTTOTA += PAR->PAR_QTPROD
					PAR->PAR_STATUS := 'T'
					PAR->(MsUnlock())

					//Atualiza Apontamentos de produção
					If !PC6->(dbSeek(PAR->PAR_FILIAL+PAR->PAR_NCICLO+PAR->PAR_ITEM+PAR->PAR_TANQUE+PAR->PAR_OP))
						Reclock("PC6",.T.)
						PC6->PC6_FILIAL := PAR->PAR_FILIAL
						PC6->PC6_NCICLO := PAR->PAR_NCICLO
						PC6->PC6_ITEM   := PAR->PAR_ITEM
						PC6->PC6_CODPRO := PAR->PAR_CODPRO
						PC6->PC6_TANQUE := PAR->PAR_TANQUE
						PC6->PC6_OP     := PAR->PAR_OP
						PC6->PC6_QUANT  := PAR->PAR_QUANT
						PC6->PC6_PEPERD := PAR->PAR_PEPERD
						PC6->PC6_QTPERD := PAR->PAR_QTPERD
						PC6->PC6_LOCAL  := PAR->PAR_LOCAL
						PC6->(MsUnlock())
					EndIf

					// Limpa os dados da medição apontada
					oGetDados:aCols[nX,_nPosQTP] := PAR->PAR_QTPROD   // Volume Prod. 20ºC
					oGetDados:aCols[nX,_nPosT20] := PAR->PAR_QTTOTA	// Volume Prod. Total 20ºC

					// Atualiza o item do ciclo que foi apontado
					U_F0400109(@oGetDados, oGetDados:nAT, @cNumCiclo, .F.)
					lTudoOk := .T.

				EndIf

			EndIf

			If lTudoOk
				IncProc('Libera tanque...')
				If PAA->(dbSeek(xFilial()+PAR->PAR_TANQUE))
					Reclock("PAA",.F.)
					PAA->PAA_STATUS := 'A'
					PAA->(MsUnlock())
				EndIf
			EndIF

		Next

		// Rateio da perda para apontamentos parciais
		If lTudoOk
			For nX := 1 to Len(oGetDados:aCols)
				ProcRegua(1)
				If PAR->(dbSeek(xFilial()+cNumCiclo+oGetDados:aCols[nx,_nPosItem]+oGetDados:aCols[nx,_nPosTank]))
					lPerda := .T.
					If PC6->(dbSeek(PAR->PAR_FILIAL+PAR->PAR_NCICLO+PAR->PAR_ITEM+PAR->PAR_TANQUE))
						Do While PC6->(!Eof()) .And. PC6->PC6_FILIAL+PC6->PC6_NCICLO+PC6->PC6_ITEM+PC6->PC6_TANQUE == ;
								PAR->PAR_FILIAL+PAR->PAR_NCICLO+PAR->PAR_ITEM+PAR->PAR_TANQUE
							If PAR->PAR_STATUS == 'T'
								PC6->(dbSkip())
								Loop
							EndIf

							IncProc('Requistando perda...')
							nPerc3 := U_F0400123(PAQ->PAQ_NCICLO, PAR->PAR_ITEM, PC6->PC6_OP) / U_F0400123(PAQ->PAQ_NCICLO)
							Reclock("PC6",.F.)
							PC6->PC6_QTPERD := RateiPC6(nPerc3)
							PC6->PC6_PEPERD := nPerc3
							PC6->(MsUnlock())

							//Lança o valor de perda por OP
							lPerda := U_F0400119(PC6->PC6_OP, PC6->PC6_CODPRO, PC6->PC6_LOCAL, PC6->PC6_QTPERD, PAQ->PAQ_TANQUE, 3)
							If !lPerda
								Exit
							EndIf
							PC6->(dbSkip())

						EndDo
						If !lPerda
							DisarmTransaction()
							lTudoOk := .F.
							Exit
						EndIf
					EndIf
				ENDIF
			Next
		EndIf

		// Acumula o total produzido no ciclo
		If (nSomaQT > 0) .And. lTudoOk
			aSaldoFin := U_F0400106(PAQ->PAQ_TANQUE, PAQ->PAQ_CODPRO, .F.)
			Reclock("PAQ",.F.)
			PAQ->PAQ_QUANT  := aSaldoFin[2]
			PAQ->PAQ_CONSU  := U_F0400123(PAQ->PAQ_NCICLO)
			PAQ->PAQ_STATUS := "3"
			PAQ->PAQ_PERDA  := nSomPerda
			PAQ->(MsUnlock())
			PAA->(dbSetOrder(1))
			nQtdeCons := PAQ->PAQ_CONSU
			oQtdeCons:Refresh()
			nQtdePerd := PAQ->PAQ_PERDA
			oQtdePerda:Refresh()
			nQtdeMat  := PAQ->PAQ_QUANT
			oQtdeMat:Refresh()
			cErro := "Ciclo de Produção Finalizado!"+CRLF+CRLF
			cErro += "Total Programado = " + TransForm(PAQ->PAQ_QTPREV, PesqPict("PAQ","PAQ_QTPREV"))+CRLF
			cErro += "Total Produzido  = " + TransForm(PAQ->PAQ_CONSU, PesqPict("PAQ","PAQ_CONSU"))+CRLF
			cErro += "Total de Perdas  = " + TransForm(PAQ->PAQ_PERDA, PesqPict("PAQ","PAQ_PERDA"))
			Help(NIL, NIL, "Produção OK", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {})
		ENDIF

	END TRANSACTION

	oGetDados:Refresh()
	oGetDados:oBrowse:Refresh()

Return nil

Static Function RateiPC6(nPerc)
	Local cQuery := ''
	Local cAlPC6 := ''
	Local cAlPC6_2 := ''
	Local nPerda := 0

	//PC6_FILIAL+PC6_NCICLO+PC6_ITEM+PC6_TANQUE+PC6_OP
	cQuery := " Select Top 1 R_E_C_N_O_ RecPC6 from "+RetSqlName('PC6')+" "
	cQuery += " Where "
	cQuery += " PC6_FILIAL = '"+PC6->PC6_FILIAL+"' And "
	cQuery += " PC6_NCICLO = '"+PC6->PC6_NCICLO+"' And "
	cQuery += " D_E_L_E_T_ = '' "
	cQuery += " Order By PC6_FILIAL+PC6_NCICLO+PC6_ITEM+PC6_TANQUE+PC6_OP Desc "
	//Obs: Somar a chave do order by porque o SQL ordena incorretamente
	cQuery := ChangeQuery(cQuery)

	cAlPC6 := MPSysOpenQuery(cQuery)

	If !(cAlPC6)->(EoF())
		If PC6->(Recno()) != (cAlPC6)->RecPC6 //Se não for o último
			nPerda := PAQ->PAQ_QUANT * nPerc 	//Abs((PAQ->PAQ_QUANT - U_F0400123(PAQ->PAQ_NCICLO))) * nPerc //Lança rateado
		Else //Se for o último
			cQuery := " Select Coalesce(Sum(PC6_QTPERD), 0) Perdas from "+RetSqlName('PC6')+" "
			cQuery += " Where "
			cQuery += " PC6_FILIAL = '"+PC6->PC6_FILIAL+"' And "
			cQuery += " PC6_NCICLO = '"+PC6->PC6_NCICLO+"' And "
			cQuery += " R_E_C_N_O_ <> "+cValToChar(PC6->(Recno()))+" And "
			cQuery += " D_E_L_E_T_ = '' "
			cQuery := ChangeQuery(cQuery)

			cAlPC6_2 := MPSysOpenQuery(cQuery)

			If !(cAlPC6_2)->(EoF())
				nPerda := PAQ->PAQ_QUANT - (cAlPC6_2)->Perdas 	//Abs((PAQ->PAQ_QUANT - U_F0400123(PAQ->PAQ_NCICLO))) - (cAlPC6_2)->Perdas
			EndIf

			(cAlPC6_2)->(DbCloseArea())
		EndIf
	EndIf

	(cAlPC6)->(DbCloseArea())

Return nPerda

 /*/{Protheus.doc} F0400123
	Retorna a quantidade consumida do ciclo
	@type  Function
	@author Gianluca Moreira
	@since 23/06/2020
	@version version
	@param cCiclo, param_type, Número do ciclo
	@return nQtdCons, return_type, Quantidade consumida
	/*/
User Function F0400123(cCiclo, cItem, cOP)

	Local aAreaPC6 := PC6->(GetArea())
	Local aAreaSBC := SBC->(GetArea())
	Local aAreaSD3 := SD3->(GetArea())
	Local aAreaSB1 := SB1->(GetArea())
	Local aAreas   := {aAreaPC6, aAreaSBC, aAreaSD3, aAreaSB1, GetArea()}
	Local nQtdCons := 0
	Local cTpMp    := ""

	Default cItem := ''
	Default cOp   := ''

	PC6->(DbSetOrder(1)) //PC6_FILIAL+PC6_NCICLO+PC6_ITEM+PC6_TANQUE+PC6_OP
	SD3->(dbSetOrder(1)) //D3_FILIAL+D3_OP+D3_COD+D3_LOCAL
	SBC->(DbSetOrder(2)) //BC_FILIAL+BC_OP+BC_SEQSD3
	If PC6->(DbSeek(FWXFilial('PC6')+AvKey(cCiclo, 'PC6_NCICLO')+IIf(Empty(cItem), '', AvKey(cItem, 'PC6_ITEM')) ))
		While !PC6->(EoF()) .And. FWXFilial('PC6')+AvKey(cCiclo, 'PC6_NCICLO')+IIf(Empty(cItem), '', AvKey(cItem, 'PC6_ITEM')) == ;
				PC6->(PC6_FILIAL+PC6_NCICLO+IIf(Empty(cItem), '', PC6->PC6_ITEM))
			If !Empty(cOp) .And. cOp != PC6->PC6_OP
				PC6->(DbSkip())
				Loop
			EndIf
			If SD3->( dbSeek( xFilial() + PC6->PC6_OP ) )
				While !SD3->( EOF() ) .and. SD3->D3_FILIAL + Alltrim(SD3->D3_OP) == FWXFilial('SD3')+PC6->PC6_OP
					// Despreza estornos
					If SD3->D3_ESTORNO == "S"
						SD3->(dbSkip())
						Loop
					EndIf
					// Despreza mão de obra no cálculo do consumo
					cTpMp := AllTrim(Posicione("SB1",1,xFilial("SB1")+SD3->D3_COD,"B1_TIPO"))
					If cTpMp == "MO"
						SD3->(dbSkip())
						Loop
					EndIf
					// Despreza produção no cálculo do consumo
					If SD3->D3_CF $ "PR0/PR1"
						SD3->(dbSkip())
						Loop
					EndIf
					// Despreza a perda de MP consumida após apontamento da OP
					If SBC->(DbSeek(FWXFilial('SBC')+SD3->(D3_OP+D3_NUMSEQ)))
						SD3->(DbSkip())
						Loop
					EndIf
					nQtdCons += SD3->D3_QUANT
					SD3->(dbSkip())
				EndDo
			EndIf
			PC6->(DbSkip())
		EndDo
	EndIf

	AEval(aAreas, {|x| RestArea(x)})
Return nQtdCons

 /*/{Protheus.doc} F0400125
	Impede que existam dois ciclos não finalizados para o mesmo tanque
	@type  Function
	@author Gianluca Moreira
	@since 25/06/2020
	@version version
	/*/
User Function F0400125()
	Local aAreaPAQ  := PAQ->(GetArea())
	Local aAreas    := {aAreaPAQ, GetArea()}
	Local cTanqProd := ''
	Local cNumCiclo := ''
	Local cQuery    := ''
	Local cAlPAQ    := ''
	Local lRet      := .T.
	Local oModel    := FWModelActive()
	Local nOper     := 0

	If oModel != Nil
		cTanqProd := oModel:GetValue('PAQMASTER', 'PAQ_TANQUE')
		cNumCiclo := oModel:GetValue('PAQMASTER', 'PAQ_NCICLO')
		nOper     := oModel:GetOperation()
	Else
		cTanqProd := PAQ->PAQ_TANQUE
		cNumCiclo := PAQ->PAQ_NCICLO
		nOper     := 10 //MODEL_OPERATION_UPDATE //Estorno
	EndIf

	If nOper == MODEL_OPERATION_INSERT .Or. nOper == 10
		cQuery := " Select PAQ_NCICLO from "+RetSqlName('PAQ')+" "
		cQuery += " Where PAQ_FILIAL = '"+FWXFilial('PAQ')+"' And "
		cQuery += "       PAQ_TANQUE = '"+cTanqProd+"'        And "
		cQuery += "       PAQ_STATUS In ('1', '2')            And " //Em aberto ou Em andamento
		cQuery += "       PAQ_NCICLO <> '"+cNumCiclo+"'       And "
		cQuery += "       D_E_L_E_T_ = ''  "
		cQuery := ChangeQuery(cQuery)

		cAlPAQ := MPSysOpenQuery(cQuery)

		If !(cAlPAQ)->(EoF())
			lRet := .F.
			Help(,,"F0400125",,"Já existe um Ciclo de Produção Em aberto ou Em andamento para o Tanque "+;
				cTanqProd+".", 1, 0,,,,,, {"Finalize os ciclos pendentes antes de prosseguir."})
		EndIf
		(cAlPAQ)->(DbCloseArea())
	EndIf

	AEval(aAreas, {|x| RestArea(x)})

Return lRet

 /*/{Protheus.doc} F0400127
	Validação de altaeração de tanques no grid do ciclo na opção de alteração
	@type  Function
	@author Michel Sander
	@since 21/07/2020
	@version version
/*/

User Function F0400127(oModel)

	Local aAreaPAQ  := PAQ->(GetArea())
	Local aAreaPAR  := PAR->(GetArea())
	Local aAreas    := {aAreaPAQ, aAreaPAR, GetArea()}
	Local cTanqProd := ''
	Local cProduto  := ''
	Local cLocal    := ''
	Local cQuery    := ''
	Local cMsg      := ''
	Local cAlPAB    := ''
	Local lRet      := .T.
	Local nOper     := 0
	Local oModelPAR := NIL
	Local nLinha    := 0
	Local nRecnoPAR := 0

	Default oModel := FWModelActive()

	nOper := oModel:GetOperation()
	If nOper != MODEL_OPERATION_UPDATE
		Return .T.
	EndIf

	oModelPAR := oModel:GetModel('PARDETAIL')

	For nLinha := 1 To oModelPAR:Length()

		nRecnoPAR := oModelPAR:GetDataID(nLinha)
		If nRecnoPAR <= 0
			Loop
		EndIf

		PAR->(DbGoto(nRecnoPAR))
		cTanqProd := oModelPAR:GetValue('PAR_TANQUE', nLinha)
		cProduto  := oModelPAR:GetValue('PAR_CODPRO', nLinha)
		cLocal    := oModelPAR:GetValue('PAR_LOCAL', nLinha)

		cQuery := " Select * from "+RetSqlName('PAB')+" "
		cQuery += " Where PAB_FILIAL = '"+PAR->PAR_FILIAL+"' And "
		cQuery += "       PAB_TANQUE = '"+PAR->PAR_TANQUE+"' And "
		cQuery += "       PAB_NCICLO = '"+PAR->PAR_NCICLO+"' And "
		cQuery += "       D_E_L_E_T_ = ''  "
		cQuery := ChangeQuery(cQuery)
		cAlPAB := MPSysOpenQuery(cQuery)

		If (cAlPAB)->(EoF())
			(cAlPAB)->(DbCloseArea())
			Loop
		EndIf
		(cAlPAB)->(DbCloseArea())

		If oModelPAR:IsDeleted(nLinha)
			lRet := .F.
			cMsg := 'Linha: '+cValToChar(nLinha)+CRLF+CRLF
			cMsg += 'Já existe leitura realizada para o tanque '+PAR->PAR_TANQUE+'. A exclusão não poderá ser realizada.'
			Help(,,"F0400127",,cMsg, 1, 0,,,,,, {})
			Exit
		EndIf

		If cTanqProd != PAR->PAR_TANQUE
			lRet := .F.
			cMsg := 'Linha: '+cValToChar(nLinha)+CRLF+CRLF
			cMsg += 'Já existe leitura realizada para o tanque '+PAR->PAR_TANQUE+'. Não é possível alterar o tanque.'
			Help(,,"F0400127",,cMsg, 1, 0,,,,,, {})
			Exit
		EndIf

		If cProduto != PAR->PAR_CODPRO
			lRet := .F.
			cMsg := 'Linha: '+cValToChar(nLinha)+CRLF+CRLF
			cMsg += 'Já existe leitura realizada para o tanque '+PAR->PAR_TANQUE+' e produto '+PAR->PAR_CODPRO+'. Não é possível alterar o produto.'
			Help(,,"F0400127",,cMsg, 1, 0,,,,,, {})
			Exit
		EndIf

		If cLocal != PAR->PAR_LOCAL
			lRet := .F.
			cMsg := 'Linha: '+cValToChar(nLinha)+CRLF+CRLF
			cMsg += 'Já existe leitura realizada para o tanque '+PAR->PAR_TANQUE+' no local '+PAR->PAR_LOCAL+'. Não é possível alterar o produto.'
			Help(,,"F0400127",,cMsg, 1, 0,,,,,, {})
			Exit
		EndIf

	Next nLinha

	AEval(aAreas, {|x| RestArea(x)})

Return lRet

/*/{Protheus.doc} PARLinOk
	Valida se o produto a ser produzido pode ser colocado no tanque indicado
	@type  Static Function
	@author Gianluca Moreira
	@since 19/11/2020
	@version version
	/*/
Static Function PARLinOk(oModelPAR)
	Local aSaldo    := {}
	Local cMsg      := ''
	Local cTanque   := ''
	Local cProduto  := ''
	Local cPrdTan   := ''
	Local nSaldo    := 0
	Local nI        := 0
	Local lRet      := .T.

	cProduto := oModelPAR:GetValue('PAR_CODPRO')
	cTanque  := oModelPAR:GetValue('PAR_TANQUE')
	aSaldo   := U_F0407901(cTanque, .T.)

	For nI := 1 To Len(aSaldo)
		cPrdTan := aSaldo[nI, 1]
		nSaldo  := aSaldo[nI, 2]

		If cProduto != cPrdTan .And. nSaldo > 0
			cMsg := 'O Tanque '+cTanque+' informado já possui saldo de um produto diferente '
			cMsg += '('+cPrdTan+') do que fora informado a ser produzido.'
			lRet := .F.
			Help(,,"PARLinOk",,cMsg, 1, 0,,,,,, {})
			Exit
		EndIf
	Next nI

Return lRet
