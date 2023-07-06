param(
    [switch]
    $Preview
)

if($Preview) {
    quarto preview ./quarto/
}
else {
    quarto render ./quarto/ --output-dir ../docs
}
