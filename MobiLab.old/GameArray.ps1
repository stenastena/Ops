<#
$array=@()
$array.Count

$arr2=@(1,2,3,4)
$arr2.Count
$arr2

#$arr3= 'Вася', 23, 'ПЕтя', 23, 3434, 'Гамадрилья'
$arr3= @('Вася', 23, 'ПЕтя', 45, 3434, 'Гамадрилья')

$arr3
$arr3.Count
#$arr3 | % {$_.GetType()}
$arr3 | ForEach-Object {$_.GetType()}
$arr3[2]
Write-Output ''
$arr3[1,4]
$arr3[1..4]
$arr3[0..200]
$arr[700]


$arr3[0..-1]
$arr3[2..-1]
$arr3[-1..0]
$arr3[-2..0]

$arr4= @($null,$null)
$arr4
$arr4[1]

$val = $null
Write-Output "Print $val val"

get-ttt
#$Error
$error.Count
$Error[6]

#>

$arr5= 'Вася', 23, 'ПЕтя', 48, 3434, 'Гамадрилья'

###################################
function Set-NewValueInArray ( $value, $array ) 
{
$array[3]=$value
#return $array
}
####################################
Write-Output 'Массив до изменений'
foreach($i in $arr5)
{
    $i
}
Write-Output '------------------------------------------'

$ValueOfArray = 'Soprano'

Set-NewValueInArray -value $valueOfArray -array $arr5

Write-Output 'Массив После изменений'
foreach($i in $arr5)
{
    $i
}
