package main_test

import (
	"testing"
	"time"

	"github.com/nathan-osman/go-sunrise"
	"github.com/stretchr/testify/assert"
)

func TestSunriseBeforeSunset(t *testing.T) {
	rise, set := sunrise.SunriseSunset(
		43.65, -79.38, // Toronto, CA
		2022, time.September, 26,
	)
	assert.True(t, rise.Before(set), "sunrise should be before sunset")
}

func TestSunriseIsInTheMorning(t *testing.T) {
	rise, _ := sunrise.SunriseSunset(
		43.65, -79.38, // Toronto, CA
		2022, time.September, 26,
	)
	// Sunrise in UTC for Toronto should be before noon UTC
	assert.Less(t, rise.UTC().Hour(), 12, "sunrise should be before noon UTC")
}
