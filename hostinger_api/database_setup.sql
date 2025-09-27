-- Create the expenses table in your Hostinger MySQL database
-- Run this SQL in your Hostinger database management panel (phpMyAdmin)

CREATE TABLE IF NOT EXISTS expenses (
    id VARCHAR(50) PRIMARY KEY,
    description TEXT NOT NULL,
    category VARCHAR(50) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert some sample data (optional)
INSERT INTO expenses (id, description, category, amount, date, status, notes) VALUES
('1', 'Office supplies', 'Office', 45.99, '2024-01-15', 'pending', 'Pens, paper, and notebooks for the team'),
('2', 'Client lunch meeting', 'Meals', 89.50, '2024-01-18', 'approved', 'Lunch with Johnson & Associates'),
('3', 'Gas for company car', 'Transportation', 65.00, '2024-01-20', 'pending', 'Fuel for client visits downtown'),
('4', 'Software subscription', 'Software', 29.99, '2024-01-22', 'approved', 'Monthly Adobe Creative Suite license'),
('5', 'Conference tickets', 'Training', 299.00, '2024-01-25', 'pending', 'Tech conference for professional development');

-- Create index for better performance
CREATE INDEX idx_expenses_date ON expenses(date);
CREATE INDEX idx_expenses_status ON expenses(status);
CREATE INDEX idx_expenses_category ON expenses(category);