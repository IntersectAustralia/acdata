class CreateMemreExports < ActiveRecord::Migration
  def self.up
    create_table :memre_exports do |t|
      t.references :dataset
      t.string :material_name
      t.string :class_name
      t.string :creator
      t.string :form_description
      t.string :name
      t.string :notes
      t.string :membrane_property_type
      t.string :membrane_measurement_technique
      t.string :membrane_type
      t.string :membrane_units
      t.string :membrane_description
      t.string :membrane_qualifier1
      t.string :membrane_qualifier2
      t.string :membrane_qualifier3

      t.timestamps
    end

    change_table :ands_related_infos do |t|
      t.references :detailable, :polymorphic => true
    end

    AndsRelatedInfo.all.each do |a|
      if a.ands_publishable_id.present?
        a.detailable_id = a.ands_publishable_id
        a.detailable_type = 'AndsRelatedInfo'
      end
    end

    change_table :ands_related_infos do |t|
      t.remove(:ands_publishable_id)
    end

    create_table :ands_parties_memre_exports, :id => false do |t|
      t.references :ands_party
      t.references :memre_export
    end
  end

  def self.down
    drop_table :memre_exports

    change_table :ands_related_infos do |t|
      t.integer :ands_publishable_id
    end

    AndsRelatedInfo.all.each do |a|
      a.ands_publishable_id = a.detailable_id
    end

    change_table :ands_related_infos do |t|
      t.remove(:detailable_id)
      t.remove(:detailable_type)
    end

    drop_table :ands_parties_memre_exports
  end
end
