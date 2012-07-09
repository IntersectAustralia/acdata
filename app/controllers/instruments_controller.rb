class InstrumentsController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource

  expose(:all_instrument_classes) { Instrument.all.collect { |i| i.instrument_class }.uniq }
  expose(:instrument_file_types) { InstrumentFileType.all.collect {|f| [f.name, f.id] }}

  def index
    @instruments = Instrument.all.sort_by {|i| [i.instrument_class, i.name]}
  end

  def new
    @instrument = Instrument.new
    set_file_type_options
    @instrument.build_instrument_rule
  end

  def create
    @instrument.instrument_file_types = InstrumentFileType.find(params[:instrument_file_type_ids]) if params[:instrument_file_type_ids]
    @instrument.instrument_rule = create_instrument_rule(@instrument, params[:instrument_rule])
    @instrument.is_available = false

    Instrument.transaction do
      begin
        @instrument.save!
        AndsHandle.assign_handle(@instrument)
        @successful = true
      rescue
        @successful = false
        raise ActiveRecord::Rollback

      end
    end

    if @successful
      redirect_to instruments_path, :notice => "The instrument has been created."
    else
      set_file_type_options
      render :action => :new
    end
  end

  def create_instrument_rule(instrument, rules)
    return if rules.blank?
    rule_lists = {}
    rules.keys.each do |key| 
      rule_lists[key] = rules[key].map{|id| InstrumentFileType.find(id).name }.join(',')
    end
    InstrumentRule.create(rule_lists)
  end

  def edit
    set_file_type_options
  end

  def list
    respond_to do |format|
      format.json {
        instruments_by_class = {}
        all_instrument_classes.each do |ic|
          instruments_by_class[ic] =
            Instrument.where(:instrument_class => ic).map{
              |i| { :name => i.name, :id => i.id }
            }
        end
        render :json => {
          :instruments => instruments_by_class
        }
      }
    end
  end

  def update
    if @instrument.update_attributes(params[:instrument])
      if params[:instrument_file_type_ids]
        @instrument.instrument_file_types = InstrumentFileType.find(params[:instrument_file_type_ids])
      else
        @instrument.instrument_file_types = []
      end
      @instrument.instrument_rule.destroy if @instrument.instrument_rule
      @instrument.instrument_rule = create_instrument_rule(@instrument, params[:instrument_rule])
      @instrument.publish if @instrument.published?
      redirect_to(instrument_path(@instrument), :notice => "The instrument has been updated.")
    else
      set_file_type_options
      render :action => :edit
    end
  end

  def mark_available
    @instrument.is_available = true
    if @instrument.save
      redirect_to instruments_path, :notice => "The instrument: #{@instrument.name} has been marked as available."
    end
  end

  def mark_unavailable
    @instrument.is_available = false
    if @instrument.save
      redirect_to instruments_path, :notice => "The instrument: #{@instrument.name} has been marked as unavailable."
    end
  end

  private
  def set_file_type_options
    @file_type_options = []
    unless @instrument.instrument_file_types.blank?
      @file_type_options =
        @instrument.instrument_file_types.map { |ft| [ft.name, ft.id] }
    end
    if (@instrument.instrument_rule.blank?)
      @metadata_selections = []
      @visualisation_selections = []
      @unique_selections = []
      @exclusive_selections = []
      @indelible_selections = []
    else
      @metadata_selections =
        file_type_ids(@instrument.instrument_rule.metadata_file_types)
      @visualisation_selections =
        file_type_ids(@instrument.instrument_rule.visualisation_file_types)
      @unique_selections =
        file_type_ids(@instrument.instrument_rule.unique_file_types)
      @exclusive_selections =
        file_type_ids(@instrument.instrument_rule.exclusive_file_types)
      @indelible_selections =
        file_type_ids(@instrument.instrument_rule.indelible_file_types)
    end
  end

  def file_type_ids(source)
    source.blank? ? [] : source.map(&:id)
  end

end
