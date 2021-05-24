#Перед запуском скрипта необходимо произвести вход в подписку Azure.
#Connect-AzureRmAccount
#Представлен второй вариант на случай, если у пользователя несколько тенантов.
#Connect-AzureRmAccount -TenantId xxxxxxxxxxxxxxxxxxxxx

#Название ресурсной группы, где будут размещаться все ресурсы
$rg="rgTechno"

#Расположение ресурсной группы
$Location="westeurope"

# Название деплоймента, чтобы потом отслеживать какое развертывание было удачным или нет и с какими event_ами
# Также, название деплоймента используется для создания уникальных именований виртуальных машин
$job = 'vm' + (Get-Date).tostring("ddMMyyyyHHmmss")

# Главный шаблон, в котором находятся все настройки. Шаблон в формате json
$template="azuredeploy.json"

# Добавочный шаблон с входными параметрами для развертывания.
# Конкретизирует отдельные параметры относительно основного шаблона.
# Если его не будет, то все параметры будут стоять по умолчанию.
$parms="azuredeploy.parameters.json"

#Создание ресурсной группы
New-AzureRmResourceGroup -Name $rg -Location $Location -force

#Основная команда для инициализации развертывания из шаблона. Должно быть закомментировано, если выполняется тестирование шаблона без развертывания.
New-AzureRmResourceGroupDeployment -Name $job -TemplateParameterFile $parms -TemplateFile $template -ResourceGroupName $rg

#Тестирование шаблона без развертывания. Комментируется, если шаблон оттестирован и предполагается развертывание.
#Test-AzureRmResourceGroupDeployment -TemplateParameterFile $parms -TemplateFile $template -ResourceGroupName $rg
