terraform {

}

variable "strings" {
    type = string
    default = " hello world\n "
}

variable "items" {
    type = list
    default = [null, null, "", "last"]
}

variable "keychains" {
    type = map
    default = {
        "hello" = "world",
        "goodbye" = "moon"
    }
}