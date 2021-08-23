/* eslint-disable no-console */
/* eslint-disable no-alert */
import { LightningElement, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { CurrentPageReference } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
//TO DO - FF - Consider deleting the below class in future
// import findRecords from '@salesforce/apex/IntakeRequestController.findRecords';

export default class IntakeRequestRecordForm extends NavigationMixin(LightningElement) {

    // INITIALIZING THE VARIABLES
    @api recordId;
    isLoading = false;
    clearErrors = false;
    nameRequired = false;
    salesCreditOnLoad = false;
    technologyOnLoad = false;
    prioritRationalRequired = false;
    salesCreditSelected = false;
    technologySelected = false;
    productRequired = false;
    priorityDriversRequired = false;
    requiredTOB = false;
    requiredFMRScoreCITOutlier = false;
    requestPathRequired = false;
    requiredDueDate = false;
    name;
    requestSubmitter;
    description;
    origin;
    requestPath;
    targetDate;
    impactedGroups;
    requestPriority;
    priorityRationale;
    account;
    product;
    offering;
    priorityDrivers;
    impactRollout;
    otherPriorityDriverDescription;
    technologyAdditionalDetails;
    alignmentNotes;
    mainCategory;
    category;
    annualEstVolumeSold;
    annualEstLoanCount;
    requestType;
    tobNumber;
    creditAuthMemo;
    fmrScore;
    citOutlier;
    asOfDate;
    additionalInfo;

    // RESET ANY ERRORS AND PREVIOUS VALUES WHEN FIRST TIME OPENING THIS COMPONENT
    @wire(CurrentPageReference)
    wiredPageRef() {
        if (this.recordId) {
            this.resetFields();
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => { this.clearErrors = true; }, 0);
        } else {
            this.resetFields();
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => { this.clearErrors = true; }, 0);
            //Because we reset all fields, setting the default value for new request
            this.requestPriority = "Baseline";
            //keeping name required since OOTB name required not working as expected
            this.nameRequired = true;
        }
    }

    //Showing modal upon the component renders
    renderedCallback() {
        this.template.querySelector(".intakeRequestModal").show();
    }

    // RESET FIELDS WHEN SAVED OR CANCELED
    resetFields() {
        this.clearErrors = false;
        this.salesCreditOnLoad = false;
        this.technologyOnLoad = false;
        this.salesCreditSelected = false;
        this.technologySelected = false;
        this.productRequired = false;
        this.priorityDriversRequired = false;
        this.requiredTOB = false;
        this.requiredFMRScoreCITOutlier = false;
        this.prioritRationalRequired = false;
        this.requestPathRequired = false;
        this.requiredDueDate = false;
        this.name = undefined;
        this.requestSubmitter = undefined;
        this.description = undefined;
        this.origin = undefined;
        this.requestPath = undefined;
        this.targetDate = undefined;
        this.impactedGroups = undefined;
        this.requestPriority = undefined;
        this.priorityRationale = undefined;
        this.account = undefined;
        this.product = undefined;
        this.offering = undefined;
        this.priorityDrivers = undefined;
        this.impactRollout = undefined;
        this.otherPriorityDriverDescription = undefined;
        this.technologyAdditionalDetails = undefined;
        this.alignmentNotes = undefined;
        this.mainCategory = undefined;
        this.category = undefined;
        this.annualEstVolumeSold = undefined;
        this.annualEstLoanCount = undefined;
        this.requestType = undefined;
        this.tobNumber = undefined;
        this.creditAuthMemo = undefined;
        this.fmrScore = undefined;
        this.citOutlier = undefined;
        this.asOfDate = undefined;
        this.additionalInfo = undefined;
        //resetting form
        const inputFields = this.template.querySelectorAll("lightning-input-field");
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
    }

    // Boolean to know editing or new record (Using for additional fields while editing the record)
    get isEditing() {
        return this.recordId ? true : false;
    }

    // CSS purpose
    get newEditForm() {
        return this.recordId ? "editIntakeForm" : "newIntakeForm";
    }

    // Title for new and edit forms
    get intakeRequestFormTitle() {
        return this.recordId ? "Edit Intake Request" : "Create Intake Request";
    }

    // LOAD FORM VALUES AND LOGIC
    handleFormLoad(event) {
        if (this.recordId) {
            // eslint-disable-next-line vars-on-top
            var record = event.detail.records;
            // eslint-disable-next-line vars-on-top
            var fields = record[this.recordId].fields;
            const ig = fields.Impacted_Groups__c.value;
            //Boolean to know if Sales/Credit already selected or not
            this.salesCreditOnLoad = ig.includes("Sales/Credit") ? true : false;
            //Boolean to know if Sales/Credit already selected or not
            this.technologyOnLoad = ig.includes("Technology") ? true : false;
        }
    }

    // ONCE A RECORD SAVED THEN NAVIGATE TO RECORD PAGE
    handleSuccess(event) {
        // console.log('Record Saved Succesfully.');
        this.resetFields();
        this.isLoading = false;
        this.template.querySelector(".intakeRequestModal").hide();
        // SHOWING SUCCESS TOAST
        if (this.recordId) {
            this.showSuccessToast("Intake Request updated.");
        } else {
            this.showSuccessToast("Intake Request created.");
        }
        // NAVIGATE TO RECORD PAGE
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: event.detail.id,
                objectApiName: "Intake_Request__c",
                actionName: "view"
            }
        });
    }

    //Success Toast
    showSuccessToast(value) {
        const evt = new ShowToastEvent({
            title: "Success!",
            message: value,
            variant: "success"
        });
        this.dispatchEvent(evt);
    }

    //Error Toast
    showErrorToast(value) {
        const evt = new ShowToastEvent({
            title: "Please review the error.",
            message: value,
            variant: "error"
        });
        this.dispatchEvent(evt);
    }

    // VALIDATING NAME WHILE FORM SUBMITTED AND SHOWING SPINNER
    handleSubmit(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        if (fields.Name.trim().length === 0) {
            this.showErrorToast("Please fill Intake Request Name.");
        } else {
            this.template.querySelector("lightning-record-edit-form").submit(fields);
            this.isLoading = true;
        }
    }

    // WHEN ANY ERROR SHOW TOAST
    handleError(event) {
        console.log("Errors: " + JSON.stringify(event.detail));
        this.isLoading = false;
        this.showErrorToast(event.detail.detail);
    }

    // NAVIGATE TO RECENT ITEMS WHEN CANCEL
    handleCancel() {
        this.isLoading = true;
        this.resetFields();
        if (this.recordId) {
            this[NavigationMixin.Navigate]({
                type: "standard__recordPage",
                attributes: {
                    recordId: this.recordId,
                    objectApiName: "Intake_Request__c",
                    actionName: "view"
                }
            });
        } else {
            this[NavigationMixin.Navigate]({
                type: "standard__objectPage",
                attributes: {
                    objectApiName: "Intake_Request__c",
                    actionName: "list"
                },
                state: {
                    filterName: "Recent"
                }
            });
        }
        this.isLoading = false;
        this.template.querySelector(".intakeRequestModal").hide();
    }

    // CAPTURE VALUES OF INPUT-FIELD WHENEVER THERE'S A CHANGE IN INPUT VALUE
    handleNameChange(event) {
        this.name = event.detail.value;
        if (event.detail.value.trim().length === 0) {
            this.nameRequired = true;
        } else {
            this.nameRequired = false;
        }
    }
    //Handlers for all field changes
    handleRequestSubmitterChange(event) {
        this.requestSubmitter = event.detail.value;
    }
    handleDescriptionChange(event) {
        this.description = event.detail.value;
    }
    handleOriginChange(event) {
        this.origin = event.detail.value;
    }
    handleRequestPathChange(event) {
        this.requestPath = event.detail.value;
        if (this.salesCreditOnLoad) {
            this.requestPathRequired = true;
        }
    }
    handleTargetDateChange(event) {
        this.targetDate = event.detail.value;
        if (this.salesCreditOnLoad) {
            this.requiredDueDate = true;
        }
    }
    handleImpactedGroupChange(event) {
        this.impactedGroups = event.detail.value;

        if (this.recordId) {
            if (this.salesCreditOnLoad && this.technologyOnLoad) {
                this.setNoImpactedGroupChange();
            }
            else if (this.salesCreditOnLoad && event.detail.value.includes("Technology")) {
                this.setTechnologyOnly();
            }
            else if (this.technologyOnLoad && event.detail.value.includes("Sales/Credit")) {
                this.setSalesCreditOnly();
            }
            else {
                this.setNoImpactedGroupChange();
            }
        }
        else {
            if (event.detail.value.includes("Sales/Credit") && event.detail.value.includes("Technology")) {
                this.setBothSalesCreditAndTechnology();
            }
            else if (event.detail.value.includes("Sales/Credit")) {
                this.setSalesCreditOnly();
            }
            else if (event.detail.value.includes("Technology")) {
                this.setTechnologyOnly();
            }
            else {
                this.setNoImpactedGroupChange();
            }
        }
    }
    setSalesCreditOnly() {
        this.salesCreditSelected = true;
        this.requestPathRequired = true;
        this.requiredDueDate = true;
        this.technologySelected = false;
        this.productRequired = false;
        this.priorityDriversRequired = false;
    }
    setTechnologyOnly() {
        this.salesCreditSelected = false;
        this.requestPathRequired = false;
        this.requiredDueDate = false;
        this.technologySelected = true;
        this.productRequired = true;
        this.priorityDriversRequired = true;
    }
    setBothSalesCreditAndTechnology() {
        this.salesCreditSelected = true;
        this.requestPathRequired = true;
        this.requiredDueDate = true;
        this.technologySelected = true;
        this.productRequired = true;
        this.priorityDriversRequired = true;
    }
    setNoImpactedGroupChange() {
        this.salesCreditSelected = false;
        this.requestPathRequired = false;
        this.requiredDueDate = false;
        this.technologySelected = false;
        this.productRequired = false;
        this.priorityDriversRequired = false;
    }

    handleRequestPriorityChange(event) {
        this.requestPriority = event.detail.value;
        if (event.detail.value === "High" || event.detail.value === "Critical") {
            this.prioritRationalRequired = true;
        } else {
            this.prioritRationalRequired = false;
        }
    }
    handlePriorityRationaleChange(event) {
        this.priorityRationale = event.detail.value;
        const priorityValue = this.template.querySelector(".requestPriorityField").value;
        if (
            event.detail.value.trim().length === 0 &&
            (priorityValue === "High" || priorityValue === "Critical")
        ) {
            this.prioritRationalRequired = true;
        } else {
            this.prioritRationalRequired = false;
        }
    }
    handleAccountChange(event) {
        this.account = event.detail.value;
    }
    handleProductChange(event) {
        this.product = event.detail.value;
    }
    handleOfferingChange(event) {
        this.offering = event.detail.value;
    }
    handlePriorityDriversChange(event) {
        this.priorityDrivers = event.detail.value;
        if (event.detail.value === "Other") {
            this.otherPriorityDriverDescriptionRequired = true;
        } else {
            this.otherPriorityDriverDescriptionRequired = false;
        }
    }
    handleImpactRolloutChange(event) {
        this.impactRollout = event.detail.value;
    }
    handleOtherPriorityDriverDescriptionChange(event) {
        this.otherPriorityDriverDescription = event.detail.value;
    }
    handleTechnologyAdditionalDetailsChange(event) {
        this.technologyAdditionalDetails = event.detail.value;
    }
    handleAlignmentNotesChange(event) {
        this.alignmentNotes = event.detail.value;
    }
    handleMainCategoryChange(event) {
        this.mainCategory = event.detail.value;
    }
    handleCategoryChange(event) {
        this.category = event.detail.value;
    }
    handleAnnualEstVolumeChange(event) {
        this.annualEstVolumeSold = event.detail.value;
    }
    handleAnnualEstLoanChange(event) {
        this.annualEstLoanCount = event.detail.value;
    }
    handleRequestTypeChange(event) {
        this.requestType = event.detail.value;
        if (event.detail.value === "Existing") {
            this.requiredTOB = true;
        } else {
            this.requiredTOB = false;
        }
    }
    handleTOBNumberChange(event) {
        this.tobNumber = event.detail.value;
    }
    handleCreditAuthMemoChange(event) {
        this.creditAuthMemo = event.detail.value;
        if (
            event.detail.value === "Yes" ||
            event.detail.value === "Yes - Criteria Not Met"
        ) {
            this.requiredFMRScoreCITOutlier = true;
        } else {
            this.requiredFMRScoreCITOutlier = false;
        }
    }
    handleFMRScoreChange(event) {
        this.fmrScore = event.detail.value;
    }
    handleCITOutlierChange(event) {
        this.citOutlier = event.detail.value;
    }
    handleAsOfDateChange(event) {
        this.asOfDate = event.detail.value;
    }
    handleAdditionalInfoChange(event) {
        this.additionalInfo = event.detail.value;
    }
}