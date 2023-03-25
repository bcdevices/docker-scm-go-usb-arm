//go:build !cgo

package main

func mainImpl() error {
	return ErrNoCGO
}
