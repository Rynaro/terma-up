# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ClickupTui::Models::Task do
  let(:task_data) do
    {
      'id' => '12345',
      'name' => 'Test Task',
      'description' => 'This is a test task description',
      'status' => {
        'status' => 'in progress',
        'color' => '#f9d71c'
      },
      'priority' => {
        'priority' => '2',
        'color' => '#ffcc00'
      },
      'assignees' => [
        {
          'id' => '123',
          'username' => 'testuser',
          'email' => 'test@example.com'
        }
      ],
      'due_date' => '1640995200000',  # Jan 1, 2022 in milliseconds
      'time_estimate' => '3600000',   # 1 hour in milliseconds
      'tags' => [
        { 'name' => 'bug' },
        { 'name' => 'urgent' }
      ]
    }
  end

  let(:task) { ClickupTui::Models::Task.new(task_data) }

  describe '#initialize' do
    it 'correctly initializes task attributes' do
      expect(task.id).to eq('12345')
      expect(task.name).to eq('Test Task')
      expect(task.description).to eq('This is a test task description')
    end
  end

  describe '#status_icon' do
    it 'returns correct icon for in progress status' do
      expect(task.status_icon).to eq('🔄')
    end

    it 'returns archive icon for archived tasks' do
      archived_task = ClickupTui::Models::Task.new(task_data.merge('archived' => true))
      expect(archived_task.status_icon).to eq('📦')
    end
  end

  describe '#priority_icon' do
    it 'returns correct icon for high priority' do
      expect(task.priority_icon).to eq('🟠')
    end
  end

  describe '#priority_label' do
    it 'returns correct label for high priority' do
      expect(task.priority_label).to eq(' [HIGH]')
    end

    it 'returns empty string for normal priority' do
      normal_task = ClickupTui::Models::Task.new(
        task_data.merge('priority' => { 'priority' => '3' })
      )
      expect(normal_task.priority_label).to eq('')
    end
  end

  describe '#has_due_date?' do
    it 'returns true when task has due date' do
      expect(task.has_due_date?).to be true
    end

    it 'returns false when task has no due date' do
      no_due_date_task = ClickupTui::Models::Task.new(
        task_data.merge('due_date' => nil)
      )
      expect(no_due_date_task.has_due_date?).to be false
    end
  end

  describe '#due_date_formatted' do
    it 'returns formatted due date' do
      expect(task.due_date_formatted).to match(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}/)
    end
  end

  describe '#estimated_time_formatted' do
    it 'returns formatted time estimate' do
      expect(task.estimated_time_formatted).to eq('1h 0m')
    end

    it 'returns nil for no time estimate' do
      no_estimate_task = ClickupTui::Models::Task.new(
        task_data.merge('time_estimate' => nil)
      )
      expect(no_estimate_task.estimated_time_formatted).to be_nil
    end
  end

  describe '#display_name' do
    it 'includes task name and priority' do
      expect(task.display_name).to eq('Test Task [HIGH] → testuser')
    end
  end
end
