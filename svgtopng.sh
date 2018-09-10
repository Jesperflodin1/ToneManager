svg=$1
baseres=$2
doubleres=$(echo "( $baseres * 2 )" | bc)
tripleres=$(echo "( $baseres * 3 )" | bc)

file=$(echo "$svg" | cut -f 1 -d '.')
file+=".png"

secondfile=$(echo "$svg" | cut -f 1 -d '.')
secondfile+="@2x.png"

thirdfile=$(echo "$svg" | cut -f 1 -d '.')
thirdfile+="@3x.png"

echo "Generating png with resolution ${baseres}:${baseres}"
svgexport $svg $file ${baseres}:${baseres}

echo "Generating png with resolution ${doubleres}:${doubleres}"
svgexport $svg $secondfile ${doubleres}:${doubleres}

echo "Generating png with resolution ${tripleres}:${tripleres}"
svgexport $svg $thirdfile ${tripleres}:${tripleres}
