[Console]::InputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8



$ErrorActionPreference = "Stop"

$sourceDir = "path to our labelled datas"

Write-Host "Source Folder: $sourceDir"


$imagesDir = Join-Path -Path $sourceDir -ChildPath "images"
$labelsDir = Join-Path -Path $sourceDir -ChildPath "labels"
$classesFile = Join-Path -Path $sourceDir -ChildPath "classes.txt"

if (-not (Test-Path -LiteralPath $imagesDir -PathType Container)) {
	throw "Images folder could not be found at : $imagesDir"
}

if (-not (Test-Path -LiteralPath $labelsDir -PathType Container)) {
	throw "Labels folder could not be found at : $labelsDir"
}

if (-not (Test-Path -LiteralPath $classesFile -PathType Leaf)) {
	throw "classes.txt could not be found at : $classesFile"
}

Write-Host "The structure of source folder was validated successfully."


$classNames = @(Get-Content -LiteralPath $classesFile | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })

$imageExtensions = @(".jpg",".jpeg",".png",".bmp",".webp",".tif",".tiff")

$imageFiles = @(Get-ChildItem -LiteralPath $imagesDir -File -Recurse | Where-Object { $imageExtensions -contains $_.Extension.ToLowerInvariant() })

$labelFiles = @(Get-ChildItem -LiteralPath $labelsDir -File -Recurse -Filter "*.txt")

Write-Host "Class number: $($classNames.Count)"
Write-Host "Image number: $($imageFiles.Count)"
Write-Host "Label number: $($labelFiles.Count)"

if ($imageFiles.Count -ne $labelFiles.Count) {
	throw "Numbers of images and labels are not equal."
}

for ($classId = 0; $classId -lt $classNames.Count; $classId++) {
	Write-Host "$classId = $($classNames[$classId])"
}


$label_controller = @{}

foreach ($labelFile in $labelFiles) {
	if ($label_controller.ContainsKey($labelFile.BaseName)) {
		throw "There are label files which have same name : $($labelFile.Name)"
	}
	
	$label_controller[$labelFile.BaseName] = $labelFile
}

$image_controller = @{}

foreach ($imageFile in $imageFiles) {
	if ($image_controller.ContainsKey($imageFile.BaseName)){
		throw "There are image files which have same name : $($imageFile.Name)"
	}
	
	$image_controller[$imageFile.BaseName] = $imageFile

	if (-not ($label_controller.ContainsKey($imageFile.BaseName))) {
		throw "There is not any label files which corresponds to the image file : $($imageFile.Name)"
	}
}

Write-Host "All label files and image files have been matched successfully."


$trainDataSetRootDir = "path to the folder which we want to put seperated labelled datas"

$trainDataImageDir = Join-Path -Path $trainDataSetRootDir -ChildPath "images\train"
$validationDataImageDir = Join-Path -Path $trainDataSetRootDir -ChildPath "images\val"
$trainDataLabelDir = Join-Path -Path $trainDataSetRootDir -ChildPath "labels\train"
$validationDataLabelDir = Join-Path -Path $trainDataSetRootDir -ChildPath "labels\val"

if (Test-Path -LiteralPath $trainDataImageDir) {
	throw "Code was stopped because of existance of the folder : $trainDataImageDir . Check the folder paths."
}

New-Item -ItemType Directory -Path $trainDataImageDir | Out-Null

if (Test-Path -LiteralPath $validationDataImageDir) {
	throw "Code was stopped because of existance of the folder : $validationDataImageDir . Check the folder paths."
}

New-Item -ItemType Directory -Path $validationDataImageDir | Out-Null

if (Test-Path -LiteralPath $trainDataLabelDir) {
	throw "Code was stopped because of existance of the folder : $trainDataLabelDir . Check the folder paths."
}

New-Item -ItemType Directory -Path $trainDataLabelDir | Out-Null

if (Test-Path -LiteralPath $validationDataLabelDir) {
	throw "Code was stopped because of existance of the folder : $validationDataLabelDir . Check the folder paths."
}

New-Item -ItemType Directory -Path $validationDataLabelDir | Out-Null

$validation_ratio = 0.1

$validationDataNumber = [Math]::Ceiling($imageFiles.Count * $validation_ratio)
$trainDataNumber = $imageFiles.Count - $validationDataNumber

$seed = 1453

$random = [System.Random]::new($seed)

$shuffledLabelFiles = @($labelFiles | Sort-Object -Property FullName)


for ($inter_counter = $shuffledLabelFiles.Count-1; $inter_counter -gt 0 ; $inter_counter--) {
	$random_index = $random.Next(0 , $inter_counter+1)

	$temp = $shuffledLabelFiles[$inter_counter]
	$shuffledLabelFiles[$inter_counter] = $shuffledLabelFiles[$random_index]
	$shuffledLabelFiles[$random_index] = $temp
}



for ($counter = 0; $counter -lt $trainDataNumber; $counter++) {
	$our_label = $shuffledLabelFiles[$counter]
	Copy-Item -LiteralPath $our_label.FullName -Destination $trainDataLabelDir

	$our_image = $image_controller[$our_label.BaseName]
	Copy-Item -LiteralPath $our_image.FullName -Destination $trainDataImageDir
}

for ($counter = 1; $counter -le $validationDataNumber; $counter++) {
	$our_label = $shuffledLabelFiles[$shuffledLabelFiles.Count - $counter]
	Copy-Item -LiteralPath $our_label.FullName -Destination $validationDataLabelDir

	$our_image = $image_controller[$our_label.BaseName]
	Copy-Item -LiteralPath $our_image.FullName -Destination $validationDataImageDir
}

Write-Host "Train and validation datas were seperated successfully."

Compress-Archive -LiteralPath ".\TrainDataSetFolder" -DestinationPath ".\TrainDataSetFolder.zip"

Write-Host "The dataset which is ready for training was saved as zip successfully."
