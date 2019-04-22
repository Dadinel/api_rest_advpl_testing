#include "protheus.ch"
#include "restful.ch"

#define ID_KEY_GLB "GlbDnlTestingREST"

//-------------------------------------------------------------------
/*/{Protheus.doc} DnlTestingREST
API REST para efetuar testes de REST no Protheus

Todos os métodos gravam, consultam e apagam os dados somente em
memória, portanto nenhum deles impacta no ambiente Protheus

@author Daniel Mendes
@since 22/04/2019
@version 1.0
/*/
//-------------------------------------------------------------------
WSRESTFUL DnlTestingREST DESCRIPTION "REST para testes! =)"

WSDATA idJSON AS STRING OPTIONAL

WSMETHOD POST DESCRIPTION "Recebe um JSON e armazena o mesmo em memória" WSSYNTAX "/v1/dnltestingrest" PATH "/v1/dnltestingrest"
WSMETHOD GET DESCRIPTION "Retorna o JSON armazenado do ID informado" WSSYNTAX "v1/dnltestingrest/{idJSON}" PATH "v1/dnltestingrest/{idJSON}"
WSMETHOD DELETE DESCRIPTION "Deleta o JSON do ID informado" WSSYNTAX "v1/dnltestingrest/{idJSON}" PATH "v1/dnltestingrest/{idJSON}"
WSMETHOD PUT DESCRIPTION "Atualiza o JSON do ID informado" WSSYNTAX "v1/dnltestingrest/{idJSON}" PATH "v1/dnltestingrest/{idJSON}"

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} POST
Coloca em memória o JSON informado

@author Daniel Mendes
@since 22/04/2019
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD POST WSSERVICE DnlTestingREST
local lResult as logical
local cID as char

if isJSONValid(self)
    lResult := .T.
    cID := postJSON(self:getContent())
    self:setStatus(201)
    self:setResponse( '{"id": "' + cID + '"}' )
else
    lResult := .F.
endif

Return lResult

//-------------------------------------------------------------------
/*/{Protheus.doc} GET
Retorna o JSON do ID informado

@author Daniel Mendes
@since 22/04/2019
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET WSSERVICE DnlTestingREST
local lResult as logical
local cJSON as char

if existJSON(self)
    cJSON := GetGlbValue( ID_KEY_GLB + self:idJSON )
    lResult := .T.
    self:setStatus(200)
    self:setResponse(cJSON)
else
    lResult := .F.
endif

Return lResult

//-------------------------------------------------------------------
/*/{Protheus.doc} DELETE
Apaga o JSON do ID informado

@author Daniel Mendes
@since 22/04/2019
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD DELETE WSSERVICE DnlTestingREST
local lResult as logical

if existJSON(self)
    lResult := .T.
    ClearGlbValue( ID_KEY_GLB + self:idJSON )
    self:setStatus(204)
else
    lResult := .F.
endif

Return lResult

//-------------------------------------------------------------------
/*/{Protheus.doc} PUT
Atualiza o JSON do ID informado

@author Daniel Mendes
@since 22/04/2019
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD PUT WSSERVICE DnlTestingREST
local lResult as logical
local cJSON as char

if existJSON(self)
    lResult := .T.
    cJSON := self:getContent()
    putJSON(self:idJSON, cJSON)
    self:setStatus(204)
    self:setResponse(cJSON)
else
    lResult := .F.
endif

Return lResult

//-------------------------------------------------------------------
/*/{Protheus.doc} isJSONValid
Valida se o JSON informado é válido

@param oSelf Objeto da classe REST

@author Daniel Mendes
@since 22/04/2019
@version 1.0
/*/
//-------------------------------------------------------------------
static function isJSONValid(oSelf)
local xError
local jJSON

jJSON := JsonObject():New()

xError := jJSON:fromJSON(oSelf:getContent())

if Empty(xError)
    lOk := .T.
else
    oSelf:setStatus(400, xError)
    lOk := .F.
endif

return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} postJSON
Grava o JSON informado na memória global do servidor

@param cJSON JSON que será gravado na memória global do servidor

@return cID ID que foi gerado para gravar o JSON na memória global do servidor

@author Daniel Mendes
@since 22/04/2019
@version 1.0
/*/
//-------------------------------------------------------------------
static function postJSON(cJSON)
local cID as char

cID := makeID()

PutGlbValue( ID_KEY_GLB + cID, cJSON )

return cID

//-------------------------------------------------------------------
/*/{Protheus.doc} putJSON
Atualiza o JSON informado na memória global do servidor

@param cID ID do JSON na memória global do servidor
@param cJSON JSON que será gravado na memória global do servidor

@author Daniel Mendes
@since 22/04/2019
@version 1.0
/*/
//-------------------------------------------------------------------
static function putJSON(cID, cJSON)

cID := ID_KEY_GLB + cID

ClearGlbValue(cID)
PutGlbValue( cID, cJSON )

return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} existJSON
Verifica se o ID informado existe na memória global do servidor

@param oSelf Objeto da classe REST

@return lExist Indica se o JSON foi encontrado na memória

@author Daniel Mendes
@since 22/04/2019
@version 1.0
/*/
//-------------------------------------------------------------------
static function existJSON(oSelf)
local cJSON as char
local lExist as logical

cJSON := GetGlbValue( ID_KEY_GLB + oSelf:idJSON )

if Empty(cJSON)
    oSelf:setStatus(404)
    lExist := .F.
else
    lExist := .T.
endif

return lExist

//-------------------------------------------------------------------
/*/{Protheus.doc} makeID
Encapsula a função FWUUIDv4 caso exista a necessidade de alterar
a forma que o ID é gerado

@return cID ID único para persistir o JSON em memória

@author Daniel Mendes
@since 22/04/2019
@version 1.0
/*/
//-------------------------------------------------------------------
static function makeID()
local cID as char

cID := FWUUIDv4()

return cID