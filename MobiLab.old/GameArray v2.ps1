$arr = ConvertFrom-Csv @'
Name,   Article,   Size
David,  TShirt,    M
Eduard, Trouwsers, S
'@

$arr[0].Name