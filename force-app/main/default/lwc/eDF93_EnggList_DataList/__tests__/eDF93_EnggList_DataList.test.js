import { createElement } from 'lwc';
import EDF93_EnggList_DataList from 'c/eDF93_EnggList_DataList';

describe('c-e-d-f-93-engg-list-data-list', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('TODO: test case generated by CLI command, please fill in test logic', () => {
        // Arrange
        const element = createElement('c-e-d-f-93-engg-list-data-list', {
            is: EDF93_EnggList_DataList
        });

        // Act
        document.body.appendChild(element);

        // Assert
        // const div = element.shadowRoot.querySelector('div');
        expect(1).toBe(1);
    });
});