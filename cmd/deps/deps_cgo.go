//go:build cgo

package main

import (
	"github.com/google/gousb"
)

func mainImpl() error {
	_ = gousb.Device{}

	return nil
}
