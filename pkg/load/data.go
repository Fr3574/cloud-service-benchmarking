package load

import (
	"encoding/csv"
	"os"
)

func writeData(file *os.File, row []string) error {
	w := csv.NewWriter(file)
	defer w.Flush()

	// Write the row to the CSV file
	if err := w.Write(row); err != nil {
		return err
	}
	return nil
}

func writeHeader(file *os.File, header []string) error {
	// Create a new CSV writer
	w := csv.NewWriter(file)
	defer w.Flush()

	// Write the header
	if err := w.Write(header); err != nil {
		return err
	}

	return nil
}
