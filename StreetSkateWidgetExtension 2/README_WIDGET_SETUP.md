# StreetSkate Widget – Setup no Xcode

Os arquivos de código já estão prontos. Siga estes passos no Xcode para ativar o widget e a Dynamic Island.

---

## 1. Criar o Widget Extension Target

1. No Xcode, vá em **File > New > Target**
2. Selecione **Widget Extension** → Next
3. Configure:
   - **Product Name:** `StreetSkateWidgetExtension`
   - **Bundle Identifier:** `br.puc-rio.ecoa.lorran.streetskate.widget`
   - ✅ Marcar **Include Live Activity**
   - ✅ Marcar **Include Configuration App Intent** (pode desmarcar se quiser, não é obrigatório)
4. Clique **Finish** → quando perguntar "Activate scheme?", clique **Activate**

---

## 2. Adicionar os arquivos ao target correto

### Arquivos que devem estar em AMBOS os targets (app principal + extension):
- `StreetSkateWidgetExtension/SessionLiveActivity.swift`

Para adicionar ao target principal:
- Selecione o arquivo no navigator
- No inspector direito (File Inspector), marque ✅ `StreetSkateWidgetExtension` **E** ✅ `SkateAppp` (ou o nome do seu target principal)

### Arquivos que ficam SÓ no target da extension:
- `StreetSkateWidgetExtension/StreetSkateWidget.swift`

### Arquivos que ficam SÓ no target principal:
- `Services/LiveActivityService.swift`
- `ViewModels/SessionViewModel/SessionViewModel.swift` (já existia)
- `Views/TrainingViews/TrainingSessionView.swift` (já existia)

---

## 3. Deletar o arquivo gerado automaticamente pelo Xcode

Quando o Xcode criou o target, ele gerou um arquivo `.swift` padrão dentro da pasta da extension (geralmente `StreetSkateWidgetExtension.swift`). **Delete esse arquivo** — ele conflita com o `StreetSkateWidget.swift` que já criamos (ambos usam `@main`).

---

## 4. Verificar o Info.plist do app principal

O `SkateAppp-Info.plist` já foi atualizado com:
```xml
<key>NSSupportsLiveActivities</key>
<true/>
<key>NSSupportsLiveActivitiesFrequentUpdates</key>
<true/>
```

Se o Xcode do seu projeto usa **Info.plist embutido nas Build Settings**, adicione essas keys via:
- Target → Info → Custom iOS Target Properties → `+`
- Key: `NSSupportsLiveActivities` → Type: Boolean → Value: YES
- Key: `NSSupportsLiveActivitiesFrequentUpdates` → Type: Boolean → Value: YES

---

## 5. Verificar entitlements

O `SkateApDebug.entitlements` já tem as keys necessárias. Garanta que o target da extension **não precisa** de entitlements especiais para Live Activities — nenhuma key extra é necessária na extension.

---

## 6. Build Settings da Extension

Verifique:
- **Deployment Target:** iOS 16.2+ (Live Activities requerem 16.1+, Dynamic Island requer 16.1+)
- **Swift Language Version:** Swift 5.9+

---

## 7. Testar

1. Rode no dispositivo físico (Live Activities **não funcionam no simulador**)
2. Inicie uma sessão no app
3. Bloqueie a tela — o widget aparece na Lock Screen
4. Em iPhone 14 Pro ou mais novo — a Dynamic Island fica ativa

---

## Estrutura de arquivos após o setup

```
Street Skate/
├── Services/
│   └── LiveActivityService.swift          ← target principal
├── ViewModels/SessionViewModel/
│   └── SessionViewModel.swift             ← target principal (atualizado)
├── Views/TrainingViews/
│   └── TrainingSessionView.swift          ← target principal (atualizado)
├── SkateAppp-Info.plist                   ← atualizado (NSSupportsLiveActivities)
├── Utilities/
│   └── SkateApDebug.entitlements          ← atualizado
└── StreetSkateWidgetExtension/
    ├── SessionLiveActivity.swift          ← AMBOS os targets
    └── StreetSkateWidget.swift            ← só a extension
```
