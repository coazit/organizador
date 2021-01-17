# == Schema Information
#
# Table name: tasks
#
#  id          :bigint           not null, primary key
#  name        :string
#  description :text
#  due_date    :date
#  category_id :bigint           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Task < ApplicationRecord
  belongs_to :category
  belongs_to :owner, class_name: 'User'
  #Relaciones
  has_many :participating_users, class_name: 'Participant'
  has_many :participants, through: :participating_users, source: :user

  #Las tareas siempre tienen participantes
  validates :participating_users, presence: true

  #Estas columnas deben existir para poder guardarse
  validates :name, :description, presence: true
  # Debe ser unico, no puede haber dos categorias con el mismo nombre
  validates :name, uniqueness: {case_sensitive: false}
  validate :due_date_validity

  #Create code
  before_create :create_code

  #Para que el modelo acepte atributos anidados
  accepts_nested_attributes_for :participating_users, allow_destroy: true

  def due_date_validity
    return if due_date.blank?
    return if due_date > Date.today
    errors.add :due_date, I18n.t('taks.errors.invalid_due_date')
  end

  def create_code
    self.code = "#{owner.id}#{Time.now.to_i.to_s(36)}#{SecureRandom.hex(8)}"
  end
end
