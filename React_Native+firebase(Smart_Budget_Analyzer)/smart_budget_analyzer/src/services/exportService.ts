import { Platform, Share } from 'react-native';
import * as FileSystem from 'expo-file-system';
import * as Sharing from 'expo-sharing';
import { Transaction } from './firestoreService';

export class ExportService {
  private static formatDate(date: Date): string {
    return date.toISOString().split('T')[0];
  }

  private static convertTransactionsToCSV(transactions: Transaction[]): string {
    // CSV Headers
    const headers = ['Date', 'Category', 'Description', 'Amount', 'Type'];
    const csvContent = [
      headers.join(','),
      ...transactions.map(transaction => {
        const date = transaction.date.toDate();
        return [
          this.formatDate(date),
          transaction.category,
          `"${transaction.description.replace(/"/g, '""')}"`, // Escape quotes in description
          Math.abs(transaction.amount),
          transaction.amount >= 0 ? 'Income' : 'Expense'
        ].join(',');
      })
    ].join('\n');

    return csvContent;
  }

  static async exportTransactionsToCSV(transactions: Transaction[]): Promise<void> {
    try {
      const csvContent = this.convertTransactionsToCSV(transactions);
      const fileName = `transactions_${this.formatDate(new Date())}.csv`;
      const filePath = `${FileSystem.documentDirectory}${fileName}`;

      // Write CSV content to a file
      await FileSystem.writeAsStringAsync(filePath, csvContent, {
        encoding: FileSystem.EncodingType.UTF8
      });

      if (Platform.OS === 'android') {
        // For Android, use Sharing API
        const canShare = await Sharing.isAvailableAsync();
        if (canShare) {
          await Sharing.shareAsync(filePath, {
            mimeType: 'text/csv',
            dialogTitle: 'Export Transactions'
          });
        }
      } else {
        // For iOS, use Share API
        await Share.share({
          url: filePath,
          title: 'Export Transactions',
          message: 'Your transactions export is ready'
        });
      }
    } catch (error) {
      console.error('Error exporting transactions:', error);
      throw new Error('Failed to export transactions');
    }
  }
}