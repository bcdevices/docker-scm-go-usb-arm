package main

import (
	"errors"
)

var ErrNoCGO = errors.New("no cgo")
var ErrNotAvailable = errors.New("not available")
