package main_test

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestModule(t *testing.T) {
	assert.Equal(t, 2+2, 4, "two plus two is equal to four")
}
