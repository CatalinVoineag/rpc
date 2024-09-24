require 'rspec'
require_relative '../find_association'

describe FindAssociation do
  describe '#call' do
    context 'belongs_to' do
      it 'returns the association file path' do
        subject = described_class.new(
          line_text: '  belongs_to :belongs_to',
          file_uri: "file://#{Dir.pwd}/spec/test_project/app/models/test.rb",
          root_path: Dir.pwd
        ).call

        expect(subject.path).to eq(
          "#{Dir.pwd}/spec/test_project/app/models/belongs_to.rb"
        )
      end

      it 'returns the association file path if class_name is present' do
        subject = described_class.new(
          line_text: "  belongs_to :belongs_to, class_name: 'belongs_to_class_name'",
          file_uri: "file://#{Dir.pwd}/spec/test_project/app/models/test.rb",
          root_path: Dir.pwd
        ).call

        expect(subject.path).to eq(
          "#{Dir.pwd}/spec/test_project/app/models/belongs_to_class_name.rb"
        )
      end

      it 'returns the association file path if through is present' do
        subject = described_class.new(
          line_text: "  belongs_to :belongs_to, through: 'belongs_to_through'",
          file_uri: "file://#{Dir.pwd}/spec/test_project/app/models/test.rb",
          root_path: Dir.pwd
        ).call

        expect(subject.path).to eq(
          "#{Dir.pwd}/spec/test_project/app/models/belongs_to_through.rb"
        )
      end

      context 'when through is a symbol' do
        it 'returns the association file path if through is present' do
          subject = described_class.new(
            line_text: '  belongs_to :belongs_to, through: :belongs_to_through',
            file_uri: "file://#{Dir.pwd}/spec/test_project/app/models/test.rb",
            root_path: Dir.pwd
          ).call

          expect(subject.path).to eq(
            "#{Dir.pwd}/spec/test_project/app/models/belongs_to_through.rb"
          )
        end
      end
    end

    context 'has_many' do
      it 'returns the association file path' do
        subject = described_class.new(
          line_text: '  has_many :has_many',
          file_uri: "file://#{Dir.pwd}/spec/test_project/app/models/test.rb",
          root_path: Dir.pwd
        ).call

        expect(subject.path).to eq(
          "#{Dir.pwd}/spec/test_project/app/models/has_many.rb"
        )
      end

      it 'returns the association file path if class_name is present' do
        subject = described_class.new(
          line_text: "  has_many :has_many, class_name: 'has_many_class_name', optional: true",
          file_uri: "file://#{Dir.pwd}/spec/test_project/app/models/test.rb",
          root_path: Dir.pwd
        ).call

        expect(subject.path).to eq(
          "#{Dir.pwd}/spec/test_project/app/models/has_many_class_name.rb"
        )
      end

      it 'returns the association file path if through is present' do
        subject = described_class.new(
          line_text: "  has_many :has_many, through: 'has_many_through'",
          file_uri: "file://#{Dir.pwd}/spec/test_project/app/models/test.rb",
          root_path: Dir.pwd
        ).call

        expect(subject.path).to eq(
          "#{Dir.pwd}/spec/test_project/app/models/has_many_through.rb"
        )
      end

      context 'when through is a symbol' do
        it 'returns the association file path if through is present' do
          subject = described_class.new(
            line_text: '  has_many :has_many, through: :has_many_through',
            file_uri: "file://#{Dir.pwd}/spec/test_project/app/models/test.rb",
            root_path: Dir.pwd
          ).call

          expect(subject.path).to eq(
            "#{Dir.pwd}/spec/test_project/app/models/has_many_through.rb"
          )
        end
      end
    end

    context 'has_one' do
      it 'returns the association file path' do
        subject = described_class.new(
          line_text: '  has_one :has_one',
          file_uri: "file://#{Dir.pwd}/spec/test_project/app/models/test.rb",
          root_path: Dir.pwd
        ).call

        expect(subject.path).to eq(
          "#{Dir.pwd}/spec/test_project/app/models/has_one.rb"
        )
      end

      it 'returns the association file path if class_name is present' do
        subject = described_class.new(
          line_text: "  has_one :has_one, class_name: 'has_one_class_name'",
          file_uri: "file://#{Dir.pwd}/spec/test_project/app/models/test.rb",
          root_path: Dir.pwd
        ).call

        expect(subject.path).to eq(
          "#{Dir.pwd}/spec/test_project/app/models/has_one_class_name.rb"
        )
      end

      it 'returns the association file path if through is present' do
        subject = described_class.new(
          line_text: "  has_one :has_one, through: 'has_one_through'",
          file_uri: "file://#{Dir.pwd}/spec/test_project/app/models/test.rb",
          root_path: Dir.pwd
        ).call

        expect(subject.path).to eq(
          "#{Dir.pwd}/spec/test_project/app/models/has_one_through.rb"
        )
      end

      context 'when through is a symbol' do
        it 'returns the association file path if through is present' do
          subject = described_class.new(
            line_text: '  has_one :has_one, through: :has_one_through',
            file_uri: "file://#{Dir.pwd}/spec/test_project/app/models/test.rb",
            root_path: Dir.pwd
          ).call

          expect(subject.path).to eq(
            "#{Dir.pwd}/spec/test_project/app/models/has_one_through.rb"
          )
        end
      end
    end
#  belongs_to :original_course_option, class_name: 'CourseOption', optional: true

  end
end
