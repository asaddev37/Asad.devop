-- Requests table for staff-to-manager requests
CREATE TABLE IF NOT EXISTS requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    staff_id INT NOT NULL,
    type VARCHAR(100) NOT NULL,
    details TEXT NOT NULL,
    status ENUM('Pending', 'Approved', 'Rejected') DEFAULT 'Pending',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (staff_id) REFERENCES Users(id) ON DELETE CASCADE
);
